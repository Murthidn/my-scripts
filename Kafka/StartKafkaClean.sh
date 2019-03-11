#!/bin/sh

KAFKA_SVC_NAME=$(docker node ls --format "{{.Hostname}}" | grep "zk-kafka")
node_name=($KAFKA_SVC_NAME)
container=$(ssh -o "StrictHostKeyChecking no" ubuntu@$node_name docker ps --format "{{.Names}}" | grep kafka[0-9])

ENV_NAME=$(printf "$(hostname)")

echo "Select type to clear Topic"
echo "0: Clear Individual Topic"
echo "1: Clear Multiple Topics"
read clearType

if [ "$clearType" -eq 1 ];then

    echo "Are you sure you want to clean Kafka Topics in \""$ENV_NAME"\" (y/n)?"
    read answer

        if [ "$answer" != "${answer#[Yy]}" ] ;then
            echo "Kafka Clean is under Progress in \""$ENV_NAME"\", please wait for 10 min..."

            start_time="`date "+%H:%M:%S"`";
            echo "Strated at "$start_time

            ssh ubuntu@$node_name docker exec -i $container sh kafka/KafkaClean.sh $clearType

            end_time="`date "+%H:%M:%S"`";

            echo "Kafka Clean is done!"
            echo "Ended at "$end_time

            else
            echo "Kafka Clean has been cancelled!"
        fi

else 
    echo "Enter Topic Name to clear messages"
    read topicName

    echo "Are you sure you want to clean messages in Topics \""$topicName"\" (y/n)?"
    read isClearIndvidualTopic

        if [ "$isClearIndvidualTopic" != "${answer#[Yy]}" ] ;then
            echo "Kafka Clean is under Progress in \""$ENV_NAME"\", please wait for 10 min..."

            start_time="`date "+%H:%M:%S"`";
            echo "Strated at "$start_time

            ssh ubuntu@$node_name docker exec -i $container sh kafka/KafkaClean.sh $clearType $topicName

            end_time="`date "+%H:%M:%S"`";

            echo "Kafka Clean is done!"
            echo "Ended at "$end_time

            else
            echo "Kafka Clean has been cancelled!"
        fi
fi
