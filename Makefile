.PHONY: up halt destroy status reload provision format start stop check topics

BROKERS := 1 2 3

up:
	@for i in $(BROKERS); do \
		echo "VM broker-$$i upping..."; \
		cd broker-$$i && vagrant up || true; \
		cd ../; \
	done
halt:
	@for i in $(BROKERS); do \
		echo "Halting VM broker-$$i..."; \
		cd broker-$$i && vagrant halt || true; \
		cd ../; \
	done
destroy:
	@for i in $(BROKERS); do \
		echo "Destroying VM broker-$$i..."; \
		cd broker-$$i && vagrant destroy -f || true; \
		cd ../; \
	done
reload:
	@for i in $(BROKERS); do \
		echo "Reloading VM broker-$$i..."; \
		cd broker-$$i && vagrant reload || true; \
		cd ../; \
	done
format:
	@CLUSTER_ID=$$(uuidgen); \
	echo "CLUSTER_ID: $$CLUSTER_ID"; \
	cd broker-1 && vagrant ssh -c "rm -rf /opt/kafka-data/kraft-combined-logs/* && /opt/kafka/bin/kafka-storage.sh format -t $$CLUSTER_ID -c /opt/kafka/config/server.properties"; \
	cd ../broker-2 && vagrant ssh -c "rm -rf /opt/kafka-data/kraft-combined-logs/* && /opt/kafka/bin/kafka-storage.sh format -t $$CLUSTER_ID -c /opt/kafka/config/server.properties"; \
	cd ../broker-3 && vagrant ssh -c "rm -rf /opt/kafka-data/kraft-combined-logs/* && /opt/kafka/bin/kafka-storage.sh format -t $$CLUSTER_ID -c /opt/kafka/config/server.properties"; \
	cd ../
start:
	@for i in $(BROKERS); do \
		echo "Starting broker-$$i..."; \
		cd broker-$$i && vagrant ssh -c "sudo systemctl start kafka"; \
		cd ../; \
	done
stop:
	@for i in $(BROKERS); do \
		echo "Stopping broker-$$i..."; \
		cd broker-$$i && vagrant ssh -c "sudo systemctl stop kafka"; \
		cd ../; \
	done
status:
	@for i in $(BROKERS); do \
		echo "Status VM broker-$$i"; \
		cd broker-$$i && vagrant ssh -c "sudo systemctl status kafka"; \
		cd ../; \
	done
check:
	@i=$$(printf "%s\n" $(BROKERS) | shuf -n 1); \
	echo "Selected broker $$i"; \
	cd broker-$$i && vagrant ssh -c "/opt/kafka/bin/kafka-cluster.sh cluster-id --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092"
list-topics:
	@i=$$(printf "%s\n" $(BROKERS) | shuf -n 1); \
	echo "Selected broker $$i"; \
	cd broker-$$i && vagrant ssh -c "/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092"
describe-topics:
	@i=$$(printf "%s\n" $(BROKERS) | shuf -n 1); \
	echo "Selected broker $$i"; \
	cd broker-$$i && vagrant ssh -c "/opt/kafka/bin/kafka-topics.sh --describe --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 --exclude-internal"
create-topic:
	@i=$$(printf "%s\n" $(BROKERS) | shuf -n 1); \
	echo "Selected broker $$i"; \
	cd broker-$$i && vagrant ssh -c "/opt/kafka/bin/kafka-topics.sh --create --topic test1 --partitions 3 --replication-factor 3 --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092"
delete-topic:
	@i=$$(printf "%s\n" $(BROKERS) | shuf -n 1); \
	echo "Selected broker $$i"; \
	cd broker-$$i && vagrant ssh -c "/opt/kafka/bin/kafka-topics.sh --delete --topic test1 --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092"
log-dirs:
	@i=$$(printf "%s\n" $(BROKERS) | shuf -n 1); \
	echo "Selected broker $$i"; \
	cd broker-$$i && vagrant ssh -c "/opt/kafka/bin/kafka-log-dirs.sh --topic-list test1 --describe --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092"
get-offsets:
	@i=$$(printf "%s\n" $(BROKERS) | shuf -n 1); \
	echo "Selected broker $$i"; \
	cd broker-$$i && vagrant ssh -c "/opt/kafka/bin/kafka-get-offsets.sh --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092"
dump-log:
	@i=$$(printf "%s\n" $(BROKERS) | shuf -n 1); \
	echo "Selected broker $$i"; \
	cd broker-$$i && vagrant ssh -c "/opt/kafka/bin/kafka-dump-log.sh \
	--print-data-log \
	--files /opt/kafka-data/kraft-combined-logs/test1-0/00000000000000000000.log \
	bootstrap.servers=kafka1:9092,kafka2:9092,kafka3:9092"
delete-records:
	@i=$$(printf "%s\n" $(BROKERS) | shuf -n 1); \
	echo "Selected broker $$i"; \
	cd broker-$$i && vagrant ssh -c "/opt/kafka/bin/kafka-delete-records.sh \
	--bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 \
	--offset-json-file <path>"
producer-perf-test:
	@i=$$(printf "%s\n" $(BROKERS) | shuf -n 1); \
	echo "Selected broker $$i"; \
	cd broker-$$i && vagrant ssh -c "/opt/kafka/bin/kafka-producer-perf-test.sh --topic test1 \
	--num-records 1000 --record-size 1024 --throughput -1 --producer-props \
	bootstrap.servers=kafka1:9092,kafka2:9092,kafka3:9092"
consume:
	@i=$$(printf "%s\n" $(BROKERS) | shuf -n 1); \
	echo "Selected broker $$i"; \
	cd broker-$$i && vagrant ssh -c "/opt/kafka/bin/kafka-console-consumer.sh --topic test1 \
	--bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 \
	--from-beginning --property print.offset=true \
	--property print.partition=true"
config-topic:
	@i=$$(printf "%s\n" $(BROKERS) | shuf -n 1); \
	echo "Selected broker $$i"; \
	cd broker-$$i && vagrant ssh -c "/opt/kafka/bin/kafka-configs.sh --describe --all --topic test1 \
	--bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092"
