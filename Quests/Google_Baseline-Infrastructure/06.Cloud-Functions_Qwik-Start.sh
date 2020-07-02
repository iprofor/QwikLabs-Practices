# First, you're going to create a simple function named helloWorld. This function writes a message to the Cloud Functions logs. It is triggered by cloud function events and accepts a callback function used to signal completion of the function.

# For this lab the cloud function event is a cloud pub/sub topic event. A pub/sub is a messaging service where the senders of messages are decoupled from the receivers of messages. When a message is sent or posted, a subscription is required for a receiver to be alerted and receive the message.

echo "/**
* Background Cloud Function to be triggered by Pub/Sub.
* This function is exported by index.js, and executed when
* the trigger topic receives a message.
*
* @param {object} data The event payload.
* @param {object} context The event metadata.
*/
exports.helloWorld = (data, context) => {
const pubSubMessage = data;
const name = pubSubMessage.data
    ? Buffer.from(pubSubMessage.data, 'base64').toString() : "Hello World";

console.log(`My Cloud Function: ${name}`);
};" > index.js



# Create a cloud storage bucket
gsutil mb -p [PROJECT_ID] gs://[BUCKET_NAME]

# Deploy your function
# When deploying a new function, you must specify --trigger-topic, --trigger-bucket, or --trigger-http. When deploying an update to an existing function, the function keeps the existing trigger unless otherwise specified.

# For this lab, you'll set the --trigger-topic as hello_world.

# Deploy the function to a pub/sub topic named hello_world, replacing [BUCKET_NAME] with the name of your bucket:

gcloud functions deploy helloWorld \
  --stage-bucket [BUCKET_NAME] \
  --trigger-topic hello_world \
  --runtime nodejs8

# If you get OperationError, ignore warning and re-run the command.


# Verify the status of the function.
gcloud functions describe helloWorld


# Test the function
# Enter this command to create a message test of the function.

DATA=$(printf 'Hello World!'|base64) && gcloud functions call helloWorld --data '{"data":"'$DATA'"}'

# View logs
# Check the logs to see your messages in the log history.
gcloud functions logs read helloWorld