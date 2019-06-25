#!/usr/bin/env bash

truncate -s 0 kafkaIsrStatus.txt
truncate -s 0 TopicsDescription.txt

kafkaContainerID=$(docker ps | grep kafka | awk '{print $1}')

existingTopics=$(docker exec -i $kafkaContainerID /usr/share/kafka/bin/kafka-topics.sh --list --zookeeper zookeeper1:2181)
array=($existingTopics)

for (( i=1; i<${#array[@]}; i++ ))
do
    docker exec -i $kafkaContainerID /usr/share/kafka/bin/kafka-topics.sh --describe --zookeeper zookeeper2:2181 --topic "${array[$i]}" >> TopicsDescription.txt
done

for (( i=1; i<${#array[@]}; i++ ))
do

	partitionCount=$(cat TopicsDescription.txt | grep ${array[$i]} | awk '{ print $2}'| head -n 1 | cut -d ':' -f2)
	
		if [[ $partitionCount -gt 1 ]];then

        rowNo=2
		isIsrSync=true

        	for ((j=0; j<$partitionCount; j++))
        	do

			isrState=$(cat TopicsDescription.txt | grep ${array[$i]} | awk '{ print $10}' | awk 'NR=='$rowNo'' | tr -cd , | wc -c)
        	let rowNo++

        		if [ $isrState == 0 ]; then
					isIsrSync=false
				fi
			done

			echo Kafka_ISR_Sync_Status,topic=${array[$i]} sync=$isIsrSync >> kafkaIsrStatus.txt

		fi
done

# ----------------------- Inserting Kakfa ISR Sync Status Data to InfluxDB ------------------------
curl -s -X POST "http://influxdb:8186/write?db=sensu" --data-binary @kafkaIsrStatus.txt > /dev/null
