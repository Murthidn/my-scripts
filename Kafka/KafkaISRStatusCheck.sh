#!/usr/bin/env bash

#Truncating the existing file
truncate -s 0 kafkaIsrStatus.txt

#Getting Kafka Container ID
kafkaContainerID=$(docker ps | grep kafka | awk '{print $1}')

#Getting Current Kafka Topics List
existingTopics=$(docker exec -i $kafkaContainerID /usr/share/kafka/bin/kafka-topics.sh --list --zookeeper zookeeper1:2181)
array=($existingTopics)

for (( i=1; i<${#array[@]}; i++ ))
do
	#Getting Topic Partition Size
	partitionCount=$(docker exec -i $kafkaContainerID /usr/share/kafka/bin/kafka-topics.sh --describe --zookeeper zookeeper1:2181 --topic "${array[$i]}" | awk '{ print $2}'| head -n 1 | cut -d ':' -f2)
	
		#Checking Partition Size, & will be proceeded if size is more than 1
		if [ $partitionCount -gt 1 ];then

        rowNo=2
		isIsrSync=true

        	for ((j=0; j<$partitionCount; j++))
        	do

        	#Getting ISR Sync Status (it will return 0, if sync is in single replica, else will return more than 0 if sync is in multiple replicas)
        	isrState=$(docker exec -i $kafkaContainerID /usr/share/kafka/bin/kafka-topics.sh --describe --zookeeper zookeeper2:2181 --topic ${array[$i]} | awk '{ print $10}' | awk 'NR=='$rowNo'' | tr -cd , | wc -c)
        	let rowNo++

        		#If any isrState has 0, then that topic is not in sync
        		if [ $isrState == 0 ]; then
					isIsrSync=false
				fi
			done

			#echo ${array[$i]} "Synch is" $isIsrSync
			echo Kafka_ISR_Sync_Status,topic=${array[$i]} sync=$isIsrSync >> kafkaIsrStatus.txt

		fi
done

# ----------------------- Inserting Kakfa ISR Sync Status Data to InfluxDB ------------------------
curl -s -X POST "http://influxdb:8186/write?db=sensu" --data-binary @kafkaIsrStatus.txt > /dev/null
