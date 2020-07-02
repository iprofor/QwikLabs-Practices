# a brief intro a producer publishes messages to a topic and a consumer creates a subscription to a topic to receive messages from it.

# Run the following command to create a topic called myTopic:
gcloud pubsub topics create myTopic

# list the topics
gcloud pubsub topics list

# delete the topics
gcloud pubsub topics delete myTopic\

# Run the following command to create a subscription called mySubscription to topic myTopic:
gcloud  pubsub subscriptions create --topic myTopic mySubscription

# list subscriptions
gcloud pubsub topics list-subscriptions myTopic

# delete subscription
gcloud pubsub subscriptions delete Test1

# Run the following command to publish the message "hello" to the topic you created previously (myTopic):
gcloud pubsub topics publish myTopic --message "Hello"

# Use the following command to pull the messages you just published from the Pub/Sub topic

# get just one
gcloud pubsub subscriptions pull mySubscription --auto-ack

# get n numbers of messages, e.g. 3
gcloud pubsub subscriptions pull mySubscription --auto-ack --limit=3
