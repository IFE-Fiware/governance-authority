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

##### Preliminal activites (done once)

1. Execute shell of your vault pod `kubectl exec -it vault-0 -- /bin/sh`. In this case pod name is `vault-0`
2. Login to vault using cmd `vault login`. You will need to provide token for auth
3. Create secret engine `vault secrets enable -path=dev kv-v2` in this case name of the engine is `dev`
4. Enable kubernetes interaction with vault `vault auth enable kubernetes`
5. Add config for kubernetes `vault write auth/kubernetes/config  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"`
6. Write policy in vault for fetching credentials by kubernetes
```
vault policy write dev-policy - <<EOF
path "dev/data/*" {
   capabilities = ["read"]
}
EOF 
```
in this example `dev-policy` is name of policy - it can be anything, and path
`dev/data/*` needs to relate existing secret engine declared in pt 3.

7. Create role in vault that will bind policy with given service account name and service account namespace

```
vault write auth/kubernetes/role/gaiax-edc_role \
      bound_service_account_names=*-iaa \
      bound_service_account_namespaces=*-iaa \
      policies=dev_policy \
      ttl=24h
```
Explanation: `gaiax-edc_role` is a role name, it can be anything. `gaiax-edc-dev*` is a name for both service accounts
and kubernetes namespaces names of services account. In this case `*` wildcard was used so to use this role in each namespace
there should be kubernetes service account created with the name ending with `iaa` additionally this service
account need to be placed in namespace with a name ending with `iaa`. If you require other namespace naming convention
then the role need to be modified with correct namespaces names. `dev-policy` is a policy name defined in pt 6.

8. Go to Vault UI and define new transit secret engine with path `transit/simpl` create encryption key `gaia-x-key1` with type `ed25519`.

IMPORTANT  
Steps 1-8 need to be executed only once , if given role, policy, already exists in vault, then there is no need of configuring them again.

##### Secrets for FC-Service

Two separate secrets are needed, their naming syntax is {{ .Release.Namespace }}-xsfc-data-service and {{ .Release.Namespace }}-xsfc-infra-service, they should be created in created before kv secret engine.
Their content is:

```
{
  "DATASTORE_FILE_PATH": "/var/lib/fc-service/filestore",
  "FEDERATED_CATALOGUE_VERIFICATION_SIGNATURES": "true",
  "GRAPHSTORE_PASSWORD": "neo12345",
  "GRAPHSTORE_QUERY_TIMEOUT_IN_SECONDS": "5",
  "GRAPHSTORE_URI": "bolt://xsfc-data-neo4j:7687",
  "KEYCLOAK_AUTH_SERVER_URL": "https://authority.be.authority1.int.simpl-europe.eu",
  "KEYCLOAK_CREDENTIALS_SECRET": "generatedsecret",
  "SPRING_DATASOURCE_PASSWORD": "postgres",
  "SPRING_DATASOURCE_URL": "jdbc:postgresql://xsfc-data-postgres:5432/postgres",
  "SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI": "https://authority.be.authority1.int.simpl-europe.eu/auth/realms/gaia-x",
  "VAULT_ADDR": "http://vault-ha.vault-ha.svc.cluster.local:8200",
  "VAULT_ADRESS": "http://vault-ha.vault-ha.svc.cluster.local:8200",
  "VAULT_TOKEN": "hvs.generatedtoken"
}
```

Where you need to modify:

| Variable name                 |     Example         | Description     |
| ----------------------        |     :-----:         | --------------- |
| KEYCLOAK_AUTH_SERVER_URL      | https://authority.be.**authority1.int.simpl-europe.eu**  | Keycloak URL |
| KEYCLOAK_CREDENTIALS_SECRET   | generatedsecret                                          | Client secret from Keycloak  |
| SPRING_DATASOURCE_URL         | jdbc:postgresql://xsfc-**data OR infra**-postgres:5432/postgres | URL to postgres - it's either data or infra for those two secrets |
| SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI  | https://authority.be.**authority1.int.simpl-europe.eu**/auth/realms/**gaia-x** | URL to Keycloak including realm |
| VAULT_ADDR/ADDRESS            | http://vault-ha.vault-ha.svc.cluster.local:8200 | Internal link to Vault service  |
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

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: 'authority1-deployer'                                       # name of the deploying app in argocd
spec:
  project: default
  source:
    repoURL: 'https://code.europa.eu/api/v4/projects/902/packages/helm/stable'
    path: '""'
    targetRevision: 0.3.1                                             # version of package
    helm:
      values: |
        values:
          branch: develop                                             # branch of repo with values - this is develop by default
        project: default                                              # Project to which the namespace is attached
        namespaceTag: authority1                                      # identifier of deployment and part of fqdn
        domainSuffix: int.simpl-europe.eu                             # last part of fqdn
        argocd:
          appname: authority1-iaa                                     # name of generated argocd app 
          namespace: argocd                                           # namespace of your argocd
        cluster:
          address: https://kubernetes.default.svc
          namespace: authority1-iaa                                   # where the app will be deployed
          kubeStateHost: kube-prometheus-stack-kube-state-metrics.devsecopstools.svc.cluster.local:8080    # link to kube-state-metrics svc
        hashicorp:
          service: "http://vault-ha.vault-ha.svc.cluster.local:8200"  # local service path to your vault
        secretEngine: dev-int                                         # container for your secrets in vault
        ejbcakeys:
          keystore:
            base64: base64encodedsuperadminkeystore                   # the whole base64 encoded string of superadmin keystore
            password: superadminkeystorepass                          # password to superadmin keystore
          truststore: 
            base64: base64encodedmanagementcatruststore               # the whole base64 encoded string of ManagementCA truststore
            password: managementcatruststorepass                      # password to ManagementCA truststore
        monitoring:
          enabled: true                                               # "true" enables the deployment of ELK stack for monitoring
    chart: authority
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: authority1-iaa                                         # where the package will be deployed
```
### Manual deployment

##### Files preparation

The suggested way for deployment, is to unpack the released package to a folder on a host where you have kubectl and helm available and configured. 

There is basically one file that you need to modify - values.yaml. 
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
  appname: authority1-iaa                         # name of generated argocd app 
  namespace: argocd                               # namespace of your argocd

cluster:
  address: https://kubernetes.default.svc
  namespace: authority1-iaa                       # where the package will be deployed
  kubeStateHost: kube-prometheus-stack-kube-state-metrics.devsecopstools.svc.cluster.local:8080    # link to kube-state-metrics svc

secretEngine: dev-int                             # container for your secrets in vault
hashicorp:
  service: "http://vault-ha.vault-ha.svc.cluster.local:8200"  # local service path to your vault

values:
  repo_URL: https://code.europa.eu/simpl/simpl-open/development/agents/governance-authority.git   # repo URL
  branch: develop                                                                                 # branch of code in repo
```

##### Deployment

After you have prepared the values file, you can start the deployment. 
Use the command prompt. Proceed to the folder where you have the Chart.yaml file and execute the following command. The dot at the end is crucial - it points to current folder to look for the chart. 

Now you can deploy the agent:

`helm install authority . `

### Monitoring

ELK stack for monitoring is added with this release.  
Its deployment can be disabled by switch the value monitoring.enabled to false.  
When it's enabled, after the stack is deployed, you can access the ELK stack UI by https://kibana.**namespacetag**.**domainsuffix**  
Default user is "elastic", its password can be extracted by kubectl command. `kubectl get secret elastic-elasticsearch-es-elastic-user -o go-template='{{.data.elastic | base64decode}}' -n {namespace}`

## Additional steps

:rotating_light: :rotating_light: :rotating_light: **Attention!!!** :rotating_light: :rotating_light: :rotating_light: <br>
<b><i>After installing the agent, there are services that connect using the TLS protocol (e.g. EJBCA). In the current phase of application development, this element must be configured manually.
The entire procedure is described in confuence:</i></b>

https://confluence.simplprogramme.eu/display/SIMPL/EJBCA+Configuration

<b><i>For the authority agent to work correctly, it is necessary to perform the actions described in the link above.</i></b>

##### Upgrade the agent

The process of implementing changes is analogous to deploying the namespace for the first time:

`helm upgrade authority . `

## Delete the deployment:

`helm uninstall authority .` 


# Troubleshooting
If you encounter issues during deployment, check the following:

- Ensure that ArgoCD is properly set up and running.
- Verify that the test01 namespace exists in your Kubernetes cluster.
- Check the ArgoCD application logs and Helm error messages for specific issues.
