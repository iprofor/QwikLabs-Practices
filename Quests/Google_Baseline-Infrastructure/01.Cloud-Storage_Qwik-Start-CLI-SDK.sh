# get the default zone
gcloud compute project-info describe --project qwiklabs-gcp-04-e36fe690bf88


# Task 1: Create a project jumphost instance
gcloud compute instances create nucleus-jumphost --machine-type f1-micro --zone us-east1-b


# Task 2: Create a Kubernetes service cluster
gcloud container clusters create nucleus-helloapp --zone us-east1-b --machine-type n1-standard-1 

# After creating your cluster, you need to get authentication credentials to interact with the cluster.
gcloud container clusters get-credentials nucleus-helloapp --zone us-east1-b

# Deploying an application to the cluster
kubectl create deployment nucleus-helloserver --image=gcr.io/google-samples/hello-app:2.0

# Expose the app on port 8080
kubectl expose deployment nucleus-helloserver --type=LoadBalancer --port 8080


# Task 3: Setup an HTTP load balancer

# Create multiple web server instances

# create a startup script to be used by every virtual machine instance. This script sets up the Nginx server upon startup:
cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF

# Create an instance template, which uses the startup script:
gcloud compute instance-templates create nginx-template \
         --metadata-from-file startup-script=startup.sh

# Create a target pool. A target pool allows a single access point to all the instances in a group and is necessary for load balancing in the future steps.
gcloud compute target-pools create nginx-pool --region us-east1

# Create a managed instance group using the instance template:
gcloud compute instance-groups managed create nginx-group \
         --base-instance-name nginx \
         --size 2 \
         --template nginx-template \
         --target-pool nginx-pool
         --region us-east1

# Now configure a firewall so that you can connect to the machines on port 80 via the EXTERNAL_IP addresses:
gcloud compute firewall-rules create www-firewall --allow tcp:80

# HTTP LOAD BALANCER

# First, create a health check. Health checks verify that the instance is responding to HTTP or HTTPS traffic:
gcloud compute http-health-checks create http-basic-check

# Define an HTTP service and map a port name to the relevant port for the instance group. Now the load balancing service can forward traffic to the named port:
gcloud compute instance-groups managed \
       set-named-ports nginx-group \
       --named-ports http:80
       --region us-east1

# Create a backend service:
gcloud compute backend-services create nginx-backend \
      --protocol HTTP --http-health-checks http-basic-check --global

# Add the instance group into the backend service:
gcloud compute backend-services add-backend nginx-backend \
    --instance-group nginx-group \
    --instance-group-region us-east1 \
    --global

# Create a default URL map that directs all incoming requests to all your instances:
gcloud compute url-maps create web-map \
    --default-service nginx-backend

# Create a target HTTP proxy to route requests to your URL map:
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map

# Create a global forwarding rule to handle and route incoming requests. A forwarding rule sends traffic to a specific target HTTP or HTTPS proxy depending on the IP address, IP protocol, and port specified. The global forwarding rule does not support multiple ports.
gcloud compute forwarding-rules create http-content-rule \
        --global \
        --target-http-proxy http-lb-proxy \
        --ports 80

# After creating the global forwarding rule, it can take several minutes for your configuration to propagate.
gcloud compute forwarding-rules list