package kafka

import (
	"fmt"
	"log/slog"
	"strings"

	"github.com/confluentinc/confluent-kafka-go/v2/kafka"
)

const (
	noTimeout = 5000
)

type Handler interface {
	HandleMessage(key []byte, message []byte, partition int32, offset kafka.Offset, consumerNumber int) error
}

type Consumer struct {
	consumer       *kafka.Consumer
	handler        Handler
	stop           bool
	consumerNumber int
}

func NewConsumer(handler Handler, addr []string, topic, consumerGroup string, consumerNumber int) (*Consumer, error) {
	conf := &kafka.ConfigMap{
		"bootstrap.servers":        strings.Join(addr, ","),
		"group.id":                 consumerGroup,
		"enable.auto.offset.store": false,
		"enable.auto.commit":       true,
		"auto.commit.interval.ms":  5000,
		"auto.offset.reset":        "earliest",
	}
	c, err := kafka.NewConsumer(conf)
	if err != nil {
		return nil, fmt.Errorf("error creates new consumer: %w", err)
	}
	if err = c.Subscribe(topic, nil); err != nil {
		return nil, err
	}
	return &Consumer{consumer: c, handler: handler, consumerNumber: consumerNumber}, nil
}

func (c *Consumer) Start() {
	for {
		if c.stop {
			break
		}
		kafkaMsg, err := c.consumer.ReadMessage(noTimeout)
		if err != nil {
			if err.(kafka.Error).IsTimeout() != true {
				slog.Error("Read message", slog.Any("err", err))
			}
		}

		if kafkaMsg == nil {
			continue
		}

		if err = c.handler.HandleMessage(kafkaMsg.Key, kafkaMsg.Value, kafkaMsg.TopicPartition.Partition, kafkaMsg.TopicPartition.Offset, c.consumerNumber); err != nil {
			slog.Error("Handle message", slog.Any("offset", kafkaMsg.TopicPartition.Offset), slog.Any("err", err))
			continue
		}

		_, err = c.consumer.StoreMessage(kafkaMsg)
		if err != nil {
			slog.Error("Store offset", slog.Any("err", err))
			continue
		}
	}
}

func (c *Consumer) Stop() error {
	c.stop = true
	if _, err := c.consumer.Commit(); err != nil {
		slog.Error("Commit offsets", slog.Any("err", err))
	}
	return c.consumer.Close()
}
