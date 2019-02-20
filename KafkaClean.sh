#!/bin/sh

KAFKA_SVC_NAME=$(docker node ls --format "{{.Hostname}}" | grep "zk-kafka")
node_name=($KAFKA_SVC_NAME)
container=$(ssh -o "StrictHostKeyChecking no" ubuntu@$node_name docker ps --format "{{.Names}}" | grep kafka[0-9])

ENV_NAME=$(printf "$(hostname)")

echo "Are you sure you want to clean Kafka Topics in \""$ENV_NAME"\" (y/n)?"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
    echo ""
    echo "Kafka Clean is under Progress in \""$ENV_NAME"\", please wait for 10 min..."
    echo ""

    start_time="`date "+%H:%M:%S"`";
    echo "Strated at "$start_time
    echo ""

    sleep 10s
    ssh ubuntu@$node_name docker exec -i $container sh kafka/KafkaClean.sh

    end_time="`date "+%H:%M:%S"`";

    echo ""    
    echo "Kafka Clean is done!"
    echo ""    
    echo "Ended at "$end_time
    echo ""

else
    echo "Kafka Clean has been cancelled!"
    echo ""
fi

#The End