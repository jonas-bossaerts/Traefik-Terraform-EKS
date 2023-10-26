# EKS Cluster Setup and config

## Scope
For this project we will setup a EKS cluster on AWS, using Terraform as IaC. After deploying the infrastructure we will need to connect to the cluster and start deploying traefik. We will setup the traefik service on the EKS Cluster so that we can route all traffic.

## Prerequisuites
You will need the following:
- An AWS account with Admin privilages
- Kubectl installed on your machine
- Terraform installed on your machine
- Helm installed on your machine

## Setup EKS and Config of EKS Cluster
### Terraform
We will first start deploying the infrastructure with Terraform.
You will find all the nessecary files in this Terraform folder to create a VPC and an EKS Cluster.
You can change the name of the cluster, the amount of desired nodes, the type of nodes, etc.
After changing all the options to your choice you can start with using the following commands.

`terraform init`

After that all dependencies are downloaded, we can start applying these changes.

`terraform apply`

Now it will print out all the changes that will happen to your infrastructure, if you are happy with these, please type yes.
The Terraform will start now setting up your infrastructure, this process can take a while.

Now after Terraform is ready with the infrastructure you can start with connecting to the cluster.
If you want to destroy the infrastructure just head back into the Terraform folder and run the following command.

`terraform destroy --auto-approve`


### Kubectl
Now we will setup the kubectl connection to our newly created cluster. Use the following command.

`aws eks update-kubeconfig --region eu-west-1 --name EKS-Cluster --profile Jonas`

Now you can test to see if the EKS cluster is connected.

`kubectl cluster-info`


### Traefik
Okay now we have an EKS cluster and connection to this cluster, next we will install traefik on this cluster and setup the dashboard so that we can use it for all other apps we will deploy. Traefik will spin up a loadbalancer, which we will use through CloudFront, which will then be linked to a domain (in my case *.jonas-bossaerts.com).

First of all install the traefik helm chart and make sure it is up to date.

`helm repo add traefik https://helm.traefik.io/traefik`

`helm repo update`

Now we will install traefik in the traefik namespace and also use some custom values that we defined in the values.yaml file in the Install Traefik folder.

`helm install traefik traefik/traefik --create-namespace --namespace=traefik --values=values.yaml`

This will create a traefik service and deployment, the service will spin up a loadbalancer which we will use to connect to.
Now you will need to add 2 security groups to the loadbalancer:
- HTTPOnlyCloudFront
- HTTPSCloudFront

These will make sure that the loadbalancer can route traffic to the CloudFront distribution.

### AWS (CloudFront, ACM & Route 53)
Now before we can create the CloudFront Distribution and Route 53 we first need to add the certificate of our jonas-bossaers.com domain into ACM (Amazon Certificate Manager).

When you create the distribution you will need to add the following items:
- In Origin Domain, select the ELB that traefik created
- Make sure it is HTTP Only
- Viewer protocol policy: Redirect HTTP to HTTPS
- Cache policy: Caching Disabled
- Origin request policy: AllViewer
- Response headers policy: SimpleCORS

Now you can edit the Distribution where you add the alternate domains like for example traefik-dashboard.jonas-bossaerts.com, make sure to use the imported certificate.

After you configured the CloudFront Distribution you can add a record for the desired subdomain in route 53. Make sure that the subdomain that you want to route is also added in CloudFront.

### Deploy Dashboard of Traefik
Now that you have Traefik on your EKS and setup everything in the back we can now deploy our settings for the Dashboard.
This can be done by applying the Dashboard-route.yaml which is in the IngressRoute folder.

`kubectl apply -f .\Dashboard-route.yaml`

In this Dashboard-route.yaml file you can change the host, for example in this case we use traefik-dashboard.jonas-bossaerts.com (we added this subdomain in the past steps in our CloudFront & Route 53).

## TO DO
To Do list for this project:
- Set up Argo CD to automate the setup for the EKS cluster (rancher and Traefik)
