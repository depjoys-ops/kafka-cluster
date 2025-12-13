package main

import (
	"fmt"
	k "go-kafka/internal/kafka"
	"log/slog"
	"os"
)

const (
	topic = "test1"
)

var addr = []string{"192.168.56.10:9092", "192.168.56.11:9092", "192.168.56.12:9092"}

func main() {
	p, err := k.NewProducer(addr)
	if err != nil {
		slog.Error(err.Error())
		os.Exit(1)
	}

	for i := 0; i < 100; i++ {
		key := i
		msg := fmt.Sprintf("Kafka message %d", i)
		if err = p.Produce(msg, key, topic); err != nil {
			slog.Error(err.Error())
		}
	}
}
