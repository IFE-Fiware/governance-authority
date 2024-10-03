# Governance Authority Agent

## Description
This project contains the configuration files required for deploying an application using Helm and ArgoCD. 
- the deployment will be done by master helm chart allowing to deploy a **Governance Authority** agent using a single command.
- templates of values.yaml files used inside *Integration* environment under `app-values` folder

## Pre-Requisites

Ensure you have the following tools installed before starting the deployment process:
- Git
- Helm
- Kubectl

Additionally, ensure you have access to a Kubernetes cluster where ArgoCD is installed.

The following versions of the elements will be used in the process:

| Pre-Requisites         |     Version     | Description                                                                                                                                     |
| ---------------------- |     :-----:     | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| DNS sub-domain name    |       N/A       | This domain will be used to address all services of the agent. <br/> example: `*.authority1.int.simpl-europe.eu`                            |  
| Kubernetes Cluster     | 1.29.x or newer | Other version *might* work but tests were performed using 1.29.x version                                                                        |
| nginx-ingress          | 1.10.x or newer | Used as ingress controller. <br/> Other version *might* work but tests were performed using 1.10.x version. <br/> Image used: `registry.k8s.io/ingress-nginx/controller:v1.10.0`  |
| cert-manager           | 1.15.x or newer | Used for automatic cert management. <br/> Other version *might* work but tests were performed using 1.15.x version. <br/> Image used: `quay.io/jetstack/cert-manager-controller::v1.15.3` |
| Hashicorp Vault        | 1.17.x or newer | Other version *might* work but tests were performed using 1.17.x version. <br/> Image used: `hashicorp/vault:1.17.2`                            |
| nfs-provisioner        | 4.0.x or newer  | Backend for *Read/Write many* volumes. <br/> Other version *might* work but tests were performed using 4.0.x version. <br/> Image used: `registry.k8s.io/sig-storage/nfs-provisioner:v4.0.8` |
| argocd                 | 2.11.x or newer | Used as GitOps tool . App of apps concept. <br/> Other version *might* work but tests were performed using 2.11.x version. <br/> Image used: `quay.io/argoproj/argocd:v2.11.3` |


## Create the Namespace
Before deploying the application, ensure that the **authority** (i.e. authority1) namespace exists in your Kubernetes cluster. If the expected namespace does not exist yet you can create it with the following steps:

### Step 1: Create the Namespace
Once the namespace variable is set, you can create the namespace using the following kubectl command:

`kubectl create namespace authority1`

### Step 2: Verify the Namespace
To ensure that the namespace was created successfully, run the following command:

`kubectl get namespaces`
<br/>This will list all the namespaces in your cluster, and you should see the one you just created listed.

## Deploy the namespace
Deploying a dedicated namespace, such as **authority**, helps isolate resources and applications within a Kubernetes cluster.

Filling the namespace with content requires the following activity:

Go to master charts directory:

`cd .\charts\`

Now you can deploy the namespace:

`helm install authority . `

:rotating_light: :rotating_light: :rotating_light: **Attention!!!** :rotating_light: :rotating_light: :rotating_light: <br>
<b><i>After installing the namespace, there are services that connect using the TLS protocol (e.g. EJBCA). In the current phase of application development, this element must be configured manually.
The entire procedure is described in confuence:</i></b>

https://confluence.simplprogramme.eu/display/SIMPL/EJBCA+Configuration

<b><i>For the namespace authority to work correctly, it is necessary to perform the actions described in the link above.</i></b>

## Change the namespace

The process of implementing changes is analogous to deploying the namespace for the first time:

`helm upgrade authority . `

## Delete the deployment:

`helm uninstall authority .` 


# Troubleshooting
If you encounter issues during deployment, check the following:

- Ensure that ArgoCD is properly set up and running.
- Verify that the test01 namespace exists in your Kubernetes cluster.
- Check the ArgoCD application logs and Helm error messages for specific issues.
