package handler

import (
	"log/slog"

	"github.com/confluentinc/confluent-kafka-go/v2/kafka"
)

type handler struct {
}

func (h *handler) HandleMessage(key []byte, message []byte, partition int32, offset kafka.Offset, consumerNumber int) error {
	slog.Info("Message",
		slog.Any("key", string(key)),
		slog.Any("message", string(message)),
		slog.Any("partition", partition),
		slog.Any("offset", offset),
		slog.Any("consumerNumber", consumerNumber))

	return nil
}

func NewHandler() *handler {
	return &handler{}
}
