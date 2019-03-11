#!/bin/sh

if [ $1 == 1 ]; then

     existingTopics=$(/usr/share/kafka/bin/kafka-topics.sh --list --zookeeper zookeeper1:2181)
     array=($existingTopics)
     for (( i=0; i<${#array[@]}; i++ ))
     do
     /usr/share/kafka/bin/kafka-topics.sh --zookeeper zookeeper1:2181 --alter --topic "${array[$i]}" --config retention.ms=1000
     done

     sleep 10s

     existingTopics=$(/usr/share/kafka/bin/kafka-topics.sh --list --zookeeper zookeeper1:2181)
     array=($existingTopics)
     for (( i=0; i<${#array[@]}; i++ ))
     do
     /usr/share/kafka/bin/kafka-topics.sh --zookeeper zookeeper1:2181 --alter --topic "${array[$i]}" --config retention.ms=86400000
     done


elif [ $1 == 0 ]; then

     /usr/share/kafka/bin/kafka-topics.sh --zookeeper zookeeper1:2181 --alter --topic $2 --config retention.ms=1000

     sleep 10s

     /usr/share/kafka/bin/kafka-topics.sh --zookeeper zookeeper1:2181 --alter --topic $2 --config retention.ms=86400000

else

echo "Invalid Input!"

fi
