# Governance Authority Agent

<!-- TOC -->
* [Governance Authority Agent](#governance-authority-agent)
  * [Description](#description)
  * [Pre-Requisites](#pre-requisites)
  * [Installation](#installation)
    * [Prerequisites](#prerequisites)
      * [Create the Namespace](#create-the-namespace)
      * [Verify the Namespace](#verify-the-namespace)
      * [Vault related tasks](#vault-related-tasks)
        * [Preliminal activites (done once)](#preliminal-activites-done-once)
        * [Secrets for FC-Service](#secrets-for-fc-service)
        * [Secret for Catalog Query Mapper Adapter](#secret-for-catalog-query-mapper-adapter)
    * [Deployment using ArgoCD](#deployment-using-argocd)
    * [Manual deployment](#manual-deployment)
        * [Files preparation](#files-preparation)
        * [Deployment](#deployment)
    * [Monitoring](#monitoring)
  * [Additional steps](#additional-steps)
        * [Upgrade the agent](#upgrade-the-agent)
  * [Delete the deployment:](#delete-the-deployment)
* [Troubleshooting](#troubleshooting)
<!-- TOC -->

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
| kube-state-metrics     | present         | Used for monitoring, Metricbeat statuses in Kibana dashboard |

## Installation

### Prerequisites

#### Create the Namespace
Once the namespace variable is set, you can create the namespace using the following kubectl command:

`kubectl create namespace authority1`

#### Verify the Namespace
To ensure that the namespace was created successfully, run the following command:

`kubectl get namespaces`
<br/>This will list all the namespaces in your cluster, and you should see the one you just created listed.

#### Vault related tasks

##### Secrets for FC-Service

One secret is needed, its naming syntax is {{ .Release.Namespace }}-xsfc-service, it should be created in created before kv secret engine.
Their content is:

```
{
  "DATASTORE_FILE_PATH": "/var/lib/fc-service/filestore",
  "FEDERATED_CATALOGUE_VERIFICATION_SIGNATURES": "true",
  "GRAPHSTORE_PASSWORD": "neo12345",
  "GRAPHSTORE_QUERY_TIMEOUT_IN_SECONDS": "5",
  "GRAPHSTORE_URI": "bolt://xsfc-neo4j:7687",
  "KEYCLOAK_AUTH_SERVER_URL": "https://authority.be.authority1.int.simpl-europe.eu",
  "KEYCLOAK_CREDENTIALS_SECRET": "generatedsecret",
  "SPRING_DATASOURCE_PASSWORD": "postgres",
  "SPRING_DATASOURCE_URL": "jdbc:postgresql://xsfc-postgres:5432/postgres",
  "SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI": "https://authority.be.authority1.int.simpl-europe.eu/auth/realms/authority",
  "VAULT_ADDR": "http://vault-common.common.svc.cluster.local:8200",
  "VAULT_ADRESS": "http://vault-common.common.svc.cluster.local:8200",
  "VAULT_TOKEN": "hvs.generatedtoken"
}
```

Where you need to modify:

| Variable name                 |     Example         | Description     |
| ----------------------        |     :-----:         | --------------- |
| KEYCLOAK_AUTH_SERVER_URL      | https://authority.be.**authority1.int.simpl-europe.eu**  | Keycloak URL |
| KEYCLOAK_CREDENTIALS_SECRET   | generatedsecret                                          | Client secret from Keycloak  |
| SPRING_DATASOURCE_URL         | jdbc:postgresql://xsfc-postgres:5432/postgres | URL to postgres - it's either data or infra for those two secrets |
| SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI  | https://authority.be.**authority1.int.simpl-europe.eu**/auth/realms/**authority** | URL to Keycloak including realm |
| VAULT_ADDR/ADDRESS            | http://vaultservice.vaultnamespace.svc.cluster.local:8200 | Internal link to Vault service  |
| VAULT_TOKEN                   | hvs.generatedtoken | Token to access the Vault  |

##### Secret for Catalog Query Mapper Adapter

One secret is needed, its naming syntax is {{ .Release.Namespace }}-adapter-simpl-backend, it should be created in created before kv secret engine.
Its content is (to be revised):

```
{
  "FEDERATED_CATALOOGUE_CLIENT_URL": "https://xsfc-server-service.authority1.int.simpl-europe.eu",
  "KEYCLOAK_CLIENT_URL": "https://authority.be.authority1.int.simpl-europe.eu",
  "SIGNER_GROUP": "simpl",
  "SIGNER_ISSUER": "did:web:example.com",
  "SIGNER_KEY": "gaia-x-key1",
  "SIGNER_NAMESPACE": "transit"
}
```
Where you need to modify:

| Variable name                 |     Example         | Description     |
| ----------------------        |     :-----:         | --------------- |
| FEDERATED_CATALOOGUE_CLIENT_URL | https://xsfc-server-service.authority1.int.simpl-europe.eu | link to fqdn of the fc-service |
| KEYCLOAK_CLIENT_URL | https://authority.be.authority1.int.simpl-europe.eu | link to fqdn of Keycloak |
| SIGNER_KEY         | gaia-x-key1 | Name of the key for Signer |
| SIGNER_NAMESPACE   | transit     | Name of secret engine with transit key |

### Deployment using ArgoCD

You can easily deploy the agent using ArgoCD. All the values mentioned in the sections below you can input in ArgoCD deployment. The repoURL gets the package directly from code.europa.eu.
targetRevision is the package version. 

When you create it, you set up the values below (example values).
The ejbca section needs to be entered after you've gotten through the whole EJBCA configuration process and have the keystore and truststore, then just resynchronise the deployment.
Remove the comments after you fill in the values to avoid line wrapping.

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: 'authority1-deployer'               # name of the deploying app in argocd
spec:
  project: default
  source:
    repoURL: 'https://code.europa.eu/api/v4/projects/902/packages/helm/stable'
    path: '""'
    targetRevision: 1.1.0                   # version of package
    helm:
      values: |
        values:
          branch: v1.1.0                    # branch of repo with values - for released version it should be the release branch
        project: default                    # Project to which the namespace is attached
        namespaceTag: authority1            # identifier of deployment and part of fqdn
        domainSuffix: int.simpl-europe.eu   # last part of fqdn
        argocd:
          appname: authority1               # name of generated argocd app 
          namespace: argocd                 # namespace of your argocd
        cluster:
          address: https://kubernetes.default.svc
          namespace: authority1             # where the app will be deployed
          commonToolsNamespace: common      # namespace where main monitoring stack is deployed
        hashicorp:
          service: "http://vault-common.common.svc.cluster.local:8200"  # local service path to your vault
          role: dev-int-role                # role created in vault for access
          secretEngine: dev-int             # container for secrets in your vault
        ejbcakeys:
          keystore:
            base64: base64encodedsuperadminkeystore        # the whole base64 encoded string of superadmin keystore
            password: superadminkeystorepass               # password to superadmin keystore
          truststore: 
            base64: base64encodedmanagementcatruststore    # the whole base64 encoded string of ManagementCA truststore
            password: managementcatruststorepass           # password to ManagementCA truststore
        monitoring:
          enabled: true                     # you can set it to false if you don't have common monitoring stack
    chart: authority
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: authority1                    # where the package will be deployed
```
### Manual deployment

##### Files preparation

Another way for deployment, is to unpack the released package to a folder on a host where you have kubectl and helm available and configured. 

There are just a few values.yaml files you need to change.
The first are the values.yaml files from the `xsfc-data-catalogue` and `xsfc-infra-catalogue` components. Make sure that `hostAliases.ip` points to your ingress controller cluster ip.  

The last one to modify is main values.yaml. 
There are a couple of variables you need to replace - described below. The rest you don't need to change.
The ejbca section needs to be entered after you've gotten through the whole EJBCA configuration process and have the keystore and truststore, then just update the deployment. 

```
project: default                                  # Project to which the namespace is attached
namespaceTag: authority1                          # identifier of deployment and part of fqdn
domainSuffix: int.simpl-europe.eu                 # last part of fqdn
ejbcakeys:
  keystore:
    base64: base64encodedsuperadminkeystore       # the whole base64 encoded string of superadmin keystore
    password: superadminkeystorepass              # password to superadmin keystore
  truststore: 
    base64: base64encodedmanagementcatruststore   # the whole base64 encoded string of ManagementCA truststore
    password: managementcatruststorepass          # password to ManagementCA truststore

argocd:
  appname: authority1                             # name of generated argocd app 
  namespace: argocd                               # namespace of your argocd

cluster:
  address: https://kubernetes.default.svc
  namespace: authority1                           # where the package will be deployed
  commonToolsNamespace: common                    # namespace where main monitoring stack is deployed

hashicorp:
  service: "http://vault-common.common.svc.cluster.local:8200"  # local service path to your vault
  role: dev-int-role                              # role created in vault for access
  secretEngine: dev-int                           # container for secrets in your vault

values:
  repo_URL: https://code.europa.eu/simpl/simpl-open/development/agents/governance-authority.git   # repo URL
  branch: v1.1.0                    # branch of repo with values - for released version it should be the release branch

monitoring:
  enabled: true                     # you can set it to false if you don't have common monitoring stack
```

##### Deployment

After you have prepared the values file, you can start the deployment. 
Use the command prompt. Proceed to the folder where you have the Chart.yaml file and execute the following command. The dot at the end is crucial - it points to current folder to look for the chart. 

Now you can deploy the agent:

`helm install authority . `

## Additional steps

:rotating_light: :rotating_light: :rotating_light: **Attention!!!** :rotating_light: :rotating_light: :rotating_light: <br>
<b><i>After installing the agent, there are services that connect using the TLS protocol (e.g. EJBCA). In the current phase of application development, this element must be configured manually.
The entire procedure is described in the code repository:</i></b>

https://code.europa.eu/simpl/simpl-open/development/iaa/charts/-/blob/develop/doc/1.0.x/EJBCA.md?ref_type=heads

<b><i>For the authority agent to work correctly, it is necessary to perform the actions described in the link above.</i></b>

Also after that, to onboard the authority, you must proceed with steps from section "Authority init - Download the TLS Gateway Governance Authority keystore" of the IAA readme:

https://code.europa.eu/simpl/simpl-open/development/iaa/charts/-/blob/develop/doc/1.0.x/README.md?ref_type=heads#authority-init---download-the-tls-gateway-governance-authority-keystore

### Monitoring

Filebeat components for monitoring are included in this release.   
Their deployment can be disabled by switching the value monitoring.enabled to false.

# Troubleshooting
If you encounter issues during deployment, check the following:

- Ensure that ArgoCD is properly set up and running.
- Verify that the namespace exists in your Kubernetes cluster.
- Check the ArgoCD application logs and Helm error messages for specific issues.
