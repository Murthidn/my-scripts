existingTopics=$(/usr/share/kafka/bin/kafka-topics.sh --list --zookeeper zookeeper1:2181)
array=($existingTopics)

for (( i=0; i<${#array[@]}; i++ ))
do
    
     /usr/share/kafka/bin/kafka-topics.sh --zookeeper zookeeper1:2181 --alter --topic "${array[$i]}" --config retention.ms=1000
done

sleep 600s

existingTopics=$(/usr/share/kafka/bin/kafka-topics.sh --list --zookeeper zookeeper1:2181)

array=($existingTopics)

for (( i=0; i<${#array[@]}; i++ ))
do
    
     /usr/share/kafka/bin/kafka-topics.sh --zookeeper zookeeper1:2181 --alter --topic "${array[$i]}" --config retention.ms=86400000

done