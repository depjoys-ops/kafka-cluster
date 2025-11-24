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
get-topics:
	@i=$$(printf "%s\n" $(BROKERS) | shuf -n 1); \
	echo "Selected broker $$i"; \
	cd broker-$$i && vagrant ssh -c "/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092"
