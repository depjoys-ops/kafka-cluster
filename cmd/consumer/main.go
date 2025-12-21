package main

import (
	"log/slog"
	"os"
	"os/signal"
	"syscall"

	"go-kafka/internal/handler"
	"go-kafka/internal/kafka"
)

const (
	topic         = "test1"
	consumerGroup = "my-group"
)

var addr = []string{"192.168.56.10:9092", "192.168.56.11:9092", "192.168.56.12:9092"}

func main() {
	c1, err := kafka.NewConsumer(handler.NewHandler(), addr, topic, consumerGroup, 1)
	if err != nil {
		slog.Error("create consumer", slog.Any("err", err))
		os.Exit(1)
	}

	c2, err := kafka.NewConsumer(handler.NewHandler(), addr, topic, consumerGroup, 2)
	if err != nil {
		slog.Error("create consumer", slog.Any("err", err))
		os.Exit(1)
	}

	c3, err := kafka.NewConsumer(handler.NewHandler(), addr, topic, consumerGroup, 3)
	if err != nil {
		slog.Error("create consumer", slog.Any("err", err))
		os.Exit(1)
	}

	go func() {
		c1.Start()
	}()
	go func() {
		c2.Start()
	}()
	go func() {
		c3.Start()
	}()

	signChan := make(chan os.Signal, 1)
	signal.Notify(signChan, syscall.SIGINT, syscall.SIGTERM)

	<-signChan
	if err = c1.Stop(); err != nil {
		slog.Error("Close consumer c1", slog.Any("err", err))
		os.Exit(1)
	}

	if err = c2.Stop(); err != nil {
		slog.Error("Close consumer c2", slog.Any("err", err))
		os.Exit(1)
	}

	if err = c3.Stop(); err != nil {
		slog.Error("Close consumer c3", slog.Any("err", err))
		os.Exit(1)
	}
}
