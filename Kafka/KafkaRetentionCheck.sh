#!/bin/sh

#Get Kafka Node and Container:
KAFKA_SVC_NAME=$(docker node ls --format "{{.Hostname}}" | grep "zk-kafka")
node_name=($KAFKA_SVC_NAME)
container=$(ssh -o "StrictHostKeyChecking no" ubuntu@$node_name docker ps --format "{{.Names}}" | grep kafka[0-9])


#Get Running Kafka Topics:
existingTopics=$(ssh ubuntu@$node_name docker exec -i $container /usr/share/kafka/bin/kafka-topics.sh --list --zookeeper zookeeper1:2181)
array=($existingTopics)

#Defining Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color


echo -e "\nStarted Kafka Retention Value Verification...\n"

echo "Total Scanned Kafka Topics List: "${#array[@]}
#Loop and validate Topics:
for (( i=0; i<${#array[@]}; i++ ))
do   
    isRetentionExists=$(ssh ubuntu@$node_name docker exec -i $container /usr/share/kafka/bin/kafka-topics.sh --describe --zookeeper zookeeper1:2181 --topic "${array[$i]}" | grep Configs:retention.ms)
    if [[ -z ${isRetentionExists} ]]; then #if null
        echo -e ${GREEN}"INFO:  Topic \"${array[$i]}\" Retention is default value (1 day)."${NC}

    else
        getRetentionValue=$(ssh ubuntu@$node_name docker exec -i $container /usr/share/kafka/bin/kafka-topics.sh --describe --zookeeper zookeeper1:2181 --topic "${array[$i]}" | awk '{ print $4}' | head -n 1 | sed 's/,.*//g' | cut -d '=' -f2)
        
        if [ $getRetentionValue == "86400000" ]; then
            echo -e ${GREEN}"INFO:  Topic \"${array[$i]}\" Retention is default value (1 day)."${NC}

        else
            echo -e ${RED}"ERROR: Topic \"${array[$i]}\" Retention value is \"$getRetentionValue\""${NC}

        fi
    fi
done
echo -e "\nEnd: Verification is done.\n"
