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

### Step 1: Modify YAML Configuration Files

The first step in configuring the application is to update the necessary YAML files. These files contain key values that define the application's environment, behavior, and settings.


#### Redis

```bash 
helm install redis bitnami/redis --version 19.6.0
```

#### Postgresql

To install Postgresql chart, update the *initdb script* in `values-authority.yaml` or `values-participant.yaml` reasonably. 
```bash
helm install postgresql bitnami/postgresql \
--version 15.5.37 \
--values < authority or participant postgres values path >
```
You can check that the initialization of the database has been successful by looking at the pod log or by connecting to it using an SQL client.
<!-- kubectl port-forward service/postgresql 5432:5432  -->

##### Example of values-authority.yaml

```yaml
primary:
  initdb:
    scripts:
      init.sql: |
        CREATE USER ejbca WITH PASSWORD 'ejbca2123' CREATEDB;
        CREATE DATABASE ejbca OWNER ejbca;
        CREATE USER keycloak WITH PASSWORD 'keycloak' CREATEDB;
        CREATE DATABASE keycloak OWNER keycloak;
        CREATE USER securityattributesprovider WITH PASSWORD 'securityattributesprovider' CREATEDB;
        CREATE DATABASE securityattributesprovider OWNER securityattributesprovider;
        CREATE USER onboarding WITH PASSWORD 'onboarding' CREATEDB;
        CREATE DATABASE onboarding OWNER onboarding;
        CREATE USER usersroles WITH PASSWORD 'usersroles' CREATEDB;
        CREATE DATABASE usersroles OWNER usersroles;
        CREATE USER identityprovider WITH PASSWORD 'identityprovider' CREATEDB;
        CREATE DATABASE identityprovider OWNER identityprovider;

```

##### Example of values-participant.yaml

```yaml
primary:
  initdb:
    scripts:
      init.sql: |
        CREATE USER keycloak WITH PASSWORD 'keycloak' CREATEDB;
        CREATE DATABASE keycloak OWNER keycloak;
        CREATE USER usersroles WITH PASSWORD 'usersroles' CREATEDB;
        CREATE DATABASE usersroles OWNER usersroles;
```

> **⚠️** The configuration examples use the users and passwords mentioned above. If you change them, ensure that your configuration reflects those changes accordingly.

#### Keycloak

TODO: explain kc-init
<!-- TODO: values-common in 0.5.0 -->

```bash
helm install keycloak bitnami/keycloak \
--version 21.2.2 \
--values < authority or participant keycloak values path >
```

<!-- TODO: remove {{ .Release.Namespace }} ? -->
##### Example of values.yaml
```yaml
apiUrl: "<authority or participant endpoint>" # example: https://participant.be.aruba-simpl.cloud
                                              # example: https://authority.be.aruba-simpl.cloud
extraEnvVars: 
  - name: KC_HOSTNAME_ADMIN_URL
    value: "< apiUrl as above >/auth" # update
  - name: KC_HOSTNAME_URL
    value: "< apiUrl as above >/auth" # update
  - name: USERS_ROLES_BASE_URL
    value: "http://users-roles.<namespace>.svc.cluster.local:8080" # update
  - name: KEYCLOAK_BASE_URL
    value: "< apiUrl as above >/auth" # update
  - name: REALM
    value: "<authority or participant>" # set this

auth:
  adminPassword: "admin"

keycloakConfigCli:
  enabled: true
  configuration:
    
    # uncomment below if you are deploying an authority 
    # authority.json: |
    #   {{- $.Files.Get "kc-init/authority-realm-export.json" -}}

    # uncomment below if you are deploying a participant 
    # participant.json: |
    #   {{- $.Files.Get "kc-init/participant-realm-export.json" -}}

postgresql:
  enabled: false

externalDatabase:
  annotations: {}
  database: keycloak
  existingSecret: ""
  existingSecretDatabaseKey: ""
  existingSecretHostKey: ""
  existingSecretPasswordKey: ""
  existingSecretPortKey: ""
  existingSecretUserKey: ""
  host: "postgresql.<namespace>.svc.cluster.local"
  password: keycloak
  port: 5432
  user: keycloak
```

#### EJBCA

> **⚠️** *Step only needed for the governance authority*

Before installing EJBCA, update the values in `values.yaml` reasonably to interact with the Postgresql instance.

```bash
helm install ejbca keyfactor/ejbca-community-helm --version 1.0.3 --values < ejbca values path > 
```
Then follow the instructions [here](../EJBCA.md) to configure EJBCA and continue with the deployment.

##### Example of values.yaml

```yaml
hostname: &hostname ejbca-community-helm.<namespace>.svc.cluster.local # update this
fullnameOverride: ejbca-community-helm
ejbca:
  env:
    HTTPSERVER_HOSTNAME: *hostname
    TLS_SETUP_ENABLED: "true"
    DATABASE_JDBC_URL: jdbc:postgresql://postgresql.<namespace>.svc.cluster.local:5432/ejbca # update this
    DATABASE_USER: "ejbca"
    DATABASE_PASSWORD: "ejbca2123"
nginx:
  host: *hostname
```

<!-- helm repo add <repo name> https://code.europa.eu/api/v4/projects/<project_id>/packages/helm/<channel> -->


#### Onboarding
> **⚠️** *Step only needed for the governance authority*

#### Prerequisites

- Possess EJBCA SuperAdmin credentials (i.e. PKCS#12 certificate - also named TrustStore - and password)
- Possess ManagementCA (also named Keystore and its password)

#### Deployment
```shell
# 770 is the project_id of this repository
helm repo add onboarding-charts https://code.europa.eu/api/v4/projects/770/packages/helm/stable

helm install onboarding onboarding-charts/onboarding \
--version 0.0.5-256.hotfix.219d6217 \
--values values.yaml
```


<!-- TODO: update "<password used for the keystore of onboarded participant> explain!!!! -->
##### Example of values.yaml
```yaml
global:
  hostTls: "tls.authority.dev.simpl-europe.eu" # this is an example, update this field
  
  # TODO: find a name to refer to this password in the configuration of the following microservices 
  keystore:
    password: "<define a password for the keystore of onboarded participant>" # update this

env:
  SPRING_DATASOURCE_URL: "jdbc:postgresql://postgresql.<namespace>.svc.cluster.local:5432/onboarding"
  SPRING_DATASOURCE_USERNAME: "onboarding"
  SPRING_DATASOURCE_PASSWORD: "onboarding"

ejbca:
  keystore:
    base64: "<base64 of the keystore>" 
    password: "<password of the keystore>"
  truststore:
    base64: "<base64 of the truststore>"
    password: "<password of the truststore>"
  enrollConfig:
    url: "https://ejbca-community-helm.<namespace>.cluster.local:30443"
    profileName: "<End Entity Certificate Profile>" # update this field, example "Onboarding TLS Profile"
    endEntityName: "<EndEntity Profile>" # update this field, example "TLS Server Profile"
    caName: "<SubCA>" # update this field, example "OnBoardingCA"
```

> **💡** Tip: Generate the *base64* of the keystore and truststore with the following command: `<keystore or trustore> | base64 --wrap=0` (0 is used to disable line wrapping)

##### Configuration
The environment variables listed below are used to define the connection details, credentials and file locations required to interact with EJBCA and manage SSL Certificates. For further configuration, view the Helm template and update the values as required.

- **Certificate Configuration**
  - The `global.hostTls` set `SIMPL_CERTIFICATE_SAN`: The Subject Alternative Name (SAN) for the certificate.
  - The value `global.keystore.password` set `SIMPL_CERTIFICATE_PASSWORD`: The password for the certificate used by the service.

- **Database Configuration**
    - `SPRING_DATASOURCE_URL`: The JDBC URL for connecting to the PostgreSQL database.
        - Format: `jdbc:postgresql://postgresql.<namespace>.svc.cluster.local:5432/onboarding`
    - `SPRING_DATASOURCE_USERNAME`: The username for the PostgreSQL database.
    - `SPRING_DATASOURCE_PASSWORD`: The password for the PostgreSQL database.

- **EJBCA Configuration**
    - The value `ejbca.enrollConfig.url` set `EJBCA_URL`: The URL for the EJBCA enrollment service.
    - The value `ejbca.enrollConfig.profileName` set `EJBCA_PROFILE_NAME`: The profile name to be used when enrolling with EJBCA.
    - The value `ejbca.enrollConfig.endEntityName` set `EJBCA_END_ENTITY_NAME`: The name of the end entity in EJBCA.
    - The value `ejbca.enrollConfig.caName` set `EJBCA_CA_NAME`: The name of the Certificate Authority (CA) in EJBCA.

- **SSL Configuration - Keystore and Truststore**
    - The value `ejbca.keystore.password` set `SPRING_SSL_BUNDLE_JKS_EJBCA_KEYSTORE_PASSWORD`: The password for the EJBCA keystore.
    - The value `ejbca.truststore.password` set `SPRING_SSL_BUNDLE_JKS_EJBCA_TRUSTSTORE_PASSWORD`: The password for the EJBCA truststore.
    - `SPRING_SSL_BUNDLE_JKS_EJBCA_KEY_ALIAS`: The alias for the key within the keystore. Default value: `superadmin`
    - `SPRING_SSL_BUNDLE_JKS_EJBCA_KEYSTORE_LOCATION`: The file path for the EJBCA keystore. Default path: `/etc/certs/keystore.p12`
    - `SPRING_SSL_BUNDLE_JKS_EJBCA_TRUSTSTORE_LOCATION`: The file path for the EJBCA truststore. Default path: `/etc/certs/truststore.jks`


#### Security Attributes Provider
> **⚠️** *Step only needed for the governance authority*

##### Deployment

```shell
# 861 is the project_id of this repository
helm repo add security-attributes-provider-charts https://code.europa.eu/api/v4/projects/861/packages/helm/stable

helm install security-attributes-provider security-attributes-provider-charts/security-attributes-provider \
--version 0.0.4 \
--values values.yaml
```

##### Example of values.yaml
```yaml
env:
  MICROSERVICE_ONBOARDING_URL: http://onboarding.<namespace>.svc.cluster.local:8080
  MICROSERVICE_USERS_ROLES_URL: http://users-roles.<namespace>.svc.cluster.local:8080
  SIMPL_EPHEMERAL_PROOF_EXPIRE_AFTER: 3D
  SPRING_DATA_REDIS_HOST: redis-master.<namespace>.svc.cluster.local
  SPRING_DATA_REDIS_PASSWORD: admin
  SPRING_DATA_REDIS_PORT: "6379"
  SPRING_DATA_REDIS_USERNAME: default
  SPRING_DATASOURCE_PASSWORD: securityattributesprovider
  SPRING_DATASOURCE_URL: jdbc:postgresql://postgresql.<namespace>.svc.cluster.local:5432/securityattributesprovider
  SPRING_DATASOURCE_USERNAME: securityattributesprovider

global:
  hostBe: authority.be.dev.simpl-europe.eu  # this is an example, update this field
  hostTls: tls.authority.dev.simpl-europe.eu # this is an example, update this field
  keystore:
    password: < password defined in the oboarding component >
```

##### Configuration

The environment variables listed below are used to define the connection details and credentials for PostgreSQL, Redis, and other services. For further configuration, view the Helm template and update the values as required.

**PostgreSQL Configuration**
  - `SPRING_DATASOURCE_URL`: The JDBC URL for connecting to the PostgreSQL database. Format: `jdbc:postgresql://postgresql.<namespace>.svc.cluster.local:5432/usersroles`
  - `SPRING_DATASOURCE_USERNAME`: The username for the PostgreSQL database. Default value: `usersroles`
  - `SPRING_DATASOURCE_PASSWORD`: The password for the PostgreSQL database. Default value: `usersroles`

**Redis Configuration**
  - `SPRING_DATA_REDIS_HOST`: The host address for the Redis service. Format: `redis-master.<namespace>.svc.cluster.local`
  - `SPRING_DATA_REDIS_PORT`: The port on which Redis is running. Default value: `6379`
  - `SPRING_DATA_REDIS_USERNAME`: The username for connecting to Redis. Default value: `default`
  - `SPRING_DATA_REDIS_PASSWORD`: The password for connecting to Redis. Default value: `admin`

**Ephemeral Proof Issuer Configuration**
  - The value `tls.gateway.url` set `SIMPL_EPHEMERAL_PROOF_ISSUER_URL`: The URL for the Ephemeral Proof Issuer service.
  - The value `global.keystore.password` set `SIMPL_CERTIFICATE_PASSWORD`: The password for the certificate used by the service.
  - `SIMPL_EPHEMERAL_PROOF_EXPIRE_AFTER` : The time to Live of the ephemeral proof in redis. Default value: `3D`, follow the spring standard of the Duration class.


#### Simpl Cloud Gateway

##### Deployment

```shell
# 771 is the project_id of this repository
helm repo add simpl-cloud-gateway-charts https://code.europa.eu/api/v4/projects/772/packages/helm/stable

helm install simpl-cloud-gateway simpl-cloud-gateway-charts/simpl-cloud-gateway \
--version 0.0.4 \
--values values.yaml
```

##### Example of values.yaml
```yaml
global:
  cors: # this is an example, update this field
    allowOrigin: https://authority.fe.dev.simpl-europe.eu,https://authority.fe.dev.simpl-europe.eu,http://localhost:4202,http://localhost:3000
  hostBe: authority.be.dev.simpl-europe.eu  # this is an example, update this field
  hostFe: authority.fe.dev.simpl-europe.eu  # this is an example, update this field
  hostTls: tls.authority.dev.simpl-europe.eu  # this is an example, update this field
  ingress:
    issuer: dev-prod
  profile: < authority or participant >

microservices:
  ejbcaUrl: http://ejbca-community-helm.<namespace>.svc.cluster.local:30080
  keycloakUrl: http://keycloak.<namespace>.svc.cluster.local
  onboardingUrl: http://onboarding.<namespace>.svc.cluster.local:8080
  securityAttributesProviderUrl: http://security-attributes-provider.<namespace>.svc.cluster.local:8080
  usersRolesUrl: http://users-roles.<namespace>.svc.cluster.local:8080
```

##### Configuration

This configuration supports two main profiles: authority and participant. Depending on the specified profile, different environment variables will be set. For further configuration, view the Helm template and update the values as required.

##### Profiles 
The value `global.profile` set `SPRING_PROFILES_ACTIVE`: This sets the active Spring profile. The value can be `authority` or `participant`.

  - If the global profile is set to `authority`, the following environment variables are configured:
      - `SAP_URL`: URL for the Security Attributes Provider. Format: `http://security-attributes-provider.<namespace>.svc.cluster.local:8080`
      - `ONBOARDING_URL`: URL for the Onboarding. Format: `http://onboarding.<namespace>.svc.cluster.local:8080`
      - `EJBCA_URL`: URL for the EJBCA. Format: `http://ejbca-community-helm.<namespace>.svc.cluster.local:30080`
      - `IDENTITY_PROVIDER_URL`: URL for the Identity Provider. Format: `http://identity-provider.<namespace>.svc.cluster.local:8080`

  - If the global profile is set to `participant`, the following environment variable is configured:
    - The value `global.authorityUrl` set `AUTHORITY_URL`: URL of the authority backend. 

##### Common Configuration

Regardless of the profile, the following environment variables are configured:

- The value `global.cors.allowOrigin` set `CORS_ALLOWED_ORIGINS`: Specifies which origins are allowed to make cross-origin requests.
- The value `miroservices.keycloakUrl` set `KEYCLOAK_URL`: The URL for the Keycloak authentication service.
- The value `miroservices.usersRolesUrl` set `USERSROLES_URL`: The URL for the Users&Roles service.
- `CORS_ALLOWED_HEADERS`: Specifies which HTTP headers are allowed in cross-origin requests.
    - Default value: `Access-Control-Allow-Headers, Access-Control-Allow-Credentials, Access-Control-Allow-Origin, Access-Control-Allow-Methods, Keep-Alive, User-Agent, Content-Type, Authorization, Tenant, Channel, Platform, Set-Cookie, geolocation, x-mobility-mode, device, Cache-Control, X-Request-With, Accept, Origin`.

#### Users Roles

##### Prerequisites

- *simpl-cloud-gateway* up and running
- *security-attributes-provider* up and running


##### Deployment

```shell
# 772 is the project_id of this repository
helm repo add users-roles-charts https://code.europa.eu/api/v4/projects/771/packages/helm/stable

helm install users-roles users-roles-charts/users-roles \
--version 0.0.41-591.hotfix.b1dfc6f7 \
--values values.yaml
```

##### Example of values.yaml
```yaml
env:
  KEYCLOAK_MASTER_PASSWORD: admin # this password was set in keycloak values.yaml
  KEYCLOAK_MASTER_USER: user
  SPRING_DATA_REDIS_HOST: redis-master.<namespace>.svc.cluster.local
  SPRING_DATA_REDIS_PASSWORD: admin
  SPRING_DATA_REDIS_PORT: "6379"
  SPRING_DATA_REDIS_USERNAME: default
  SPRING_DATASOURCE_PASSWORD: usersroles
  SPRING_DATASOURCE_URL: jdbc:postgresql://postgresql.<namespace>.svc.cluster.local:5432/usersroles
  SPRING_DATASOURCE_USERNAME: usersroles

global:
  hostBe: authority.be.dev.simpl-europe.eu  # this is an example, update this field
  hostTls: tls.authority.dev.simpl-europe.eu  # this is an example, update this field
  keystore:
    password: < password defined in the oboarding component >
  profile: <authority or participant>
```

#### Configuration

The environment variables listed below are used to define the connection details for PostgreSQL, Redis, Keycloak, and other services. For further configuration, view the Helm template and update the values as required.

**Database Configuration**
  - `SPRING_DATASOURCE_URL`: The JDBC URL for connecting to the PostgreSQL database. Format: `jdbc:postgresql://postgresql.<namespace>.svc.cluster.local:5432/usersroles`
  - `SPRING_DATASOURCE_USERNAME`: The username for the PostgreSQL database.
  - `SPRING_DATASOURCE_PASSWORD`: The password for the PostgreSQL database.

**Redis Configuration**
  - `SPRING_DATA_REDIS_HOST`: The host address for the Redis service. Format: `redis-master.<namespace>.svc.cluster.local`
  - `SPRING_DATA_REDIS_PORT`: The port on which Redis is running. Default value: `6379`
  - `SPRING_DATA_REDIS_USERNAME`: The username for connecting to Redis.
  - `SPRING_DATA_REDIS_PASSWORD`: The password for connecting to Redis.

**Keycloak Configuration**
  - The value `global.hostBe` set `KEYCLOAK_URL`: The URL for the Keycloak authentication service.
  - The value `global.profile` set `KEYCLOAK_APP_REALM`: The realm to be used for the application within Keycloak.

**Client Authority Configuration**
  - The value `global.hostTls` set `CLIENT_AUTHORITY_URL`: The URL for the client authority service.
  - The value `global.keystore.password` set `CLIENT_CERTIFICATE_PASSWORD`: The password for the client certificate.

#### Frontend

##### Deployment
```shell
helm repo add simpl-fe-charts https://code.europa.eu/api/v4/projects/769/packages/helm/stable
helm install simpl-fe simpl-fe-charts/simpl-fe \
--version 0.0.4-620.hotfix.48569299 \
--values values.yaml
```

##### Example of values.yaml
```yaml
hostFe: authority.fe.dev.simpl-europe.eu # this is an example, update this field
cors: # this is an example, update this field
  allowOrigin: https://authority.be.dev.simpl-europe.eu,https://authority.fe.dev.simpl-europe.eu,http://localhost:4202,http://localhost:4203,http://localhost:3000
ingress:
  issuer: dev-prod

env:
- name: APPLICATION
  value: <onboarding or participant-utility>
- name: API_URL
  value: "https://authority.be.dev.simpl-europe.eu" # this is an example, update this field
- name: KEYCLOAK_URL
  value: "https://authority.be.dev.simpl-europe.eu/auth" # this is an example, update this field
- name: KEYCLOAK_REALM
  value: "<authority or participant>" 
- name: KEYCLOAK_CLIENT_ID
  value: "frontend-cli"
```

##### Configuration
The configuration provides details on the backend and frontend host URLs, CORS allowed origins, ingress issuer, and environment variables for the onboarding application. For further configuration, view the Helm template and update the values as required.

**Frontend Host Configuration**
  - `hostFe`: The hostname for the frontend service. Value: `my.frontend.host`

**CORS Configuration - Allowed Origins**
  - `cors.allowOrigin`: Specifies the origins that are allowed to access the application resources via cross-origin requests.
    - Value: `https://my.frontend.host, https://participant.fe.aruba-simpl.cloud, http://localhost:4202, http://localhost:4203, http://localhost:3000`

**Ingress Configuration - Issuer**
  - `ingress.issuer`: The issuer for the ingress, which is typically used for managing TLS certificates. Value: `your-issuer-ingress`

**Environment Variables**
  - `APPLICATION`: The name of the application. Value: `onboarding` if you are deploying an authority. Value: `participant-utility` if your are deploying 
  - `API_URL`: The URL for the API backend. Value: `https://my.backend.host`
**Keycloak Configuration**
  - `KEYCLOAK_URL`: The URL for the Keycloak authentication service. Value: `https://my.backend.host/auth`
  - `KEYCLOAK_REALM`: The Keycloak realm that the application uses for authentication. Value: `authority`
  - `KEYCLOAK_CLIENT_ID`: The client ID used by the application to authenticate with Keycloak. Value: `frontend-cli`

#### TLS Gateway

This microservice is a gateway for inbound Tier 2 API operation between agents and work only in https on mTLS.

##### Prerequisites

- All the previous microservices up and runnning

##### Deployment

```shell
helm repo add tls-gateway-charts https://code.europa.eu/api/v4/projects/860/packages/helm/stable
helm install tls-gateway tls-gateway-charts/tls-gateway \
--version 0.0.5 \
--values values.yaml
```

##### Example of values.yaml
```yaml
global:
  authorityUrl: https://authority.be.dev.simpl-europe.eu # this is an example, update this field
  cors: # this is an example, update this field
    allowOrigin: https://authority.fe.dev.simpl-europe.eu,https://authority.fe.dev.simpl-europe.eu,http://localhost:4202,http://localhost:3000
  profile: <authority or participant>
microservices:
  securityAttributesProviderUrl: http://security-attributes-provider.<namespace>.svc.cluster.local:8080
ssl:
  keyStore:
    base64: "<base64 of the keystore>" # get the keystore as explained in Configuration
    password: "<password defined in the oboarding component>"
  trustStore:
    base64:  "<base64 of the truststore>" # get the truststore as explained in Configuration
    password: "<password defined in the oboarding component>"
```

> **💡** Tip: Generate the *base64* of the keystore and truststore with the following command: `<keystore or trustore> | base64 --wrap=0` (0 is used to disable line wrapping)

##### Configuration

######  Download the TLS Gateway Governance Authority keystore
> **⚠️** *Step required for governance only, a participant MUST be onboarded through the application UI by following the onboarding process* 

To initialize the authority, you must send a `POST` request to the following API endpoint of the `security-attributes-provider`: `http://localhost:8080/participant/initialize`.

To initialize the authority, you must call this API `POST` of the `security-attributes-provider`. Since the API requires authentication, you need to obtain a JWT from Keycloak for a user with the **T2IAA_M** role. In this example, we use the preconfigured user `e.j`. Here is an example of how to obtain the token and call the API.

```bash
# Authentication flow - Direct Access Grants must be enbled for frontend-cli in Keycloak clients settings
curl --location 'https://authority.be.dev.simpl-europe.eu/auth/realms/authority/protocol/openid-connect/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=password' \
--data-urlencode 'client_id=frontend-cli' \
--data-urlencode 'password=password' \
--data-urlencode 'username=e.j'
```

Alternately, you can obtain a JWT without needing to modify the Keycloak client settings for the `frontend-cli` by interacting with the authority frontend through the following API:
 `https://<your-domain>/application/additional-request`, for example `https://authority.fe.authority1.int.simpl-europe.eu/application/additional-request`.
 
To retrieve the token open your browser and navigate to that url. Perform the requested login and open the *Network* tab in the browser's *DevTools*.

![](./imgs/Access%20token.png)

Since this is an internal endpoint, you'll need to set up a port forward on the microservice to access it. In this example, we assume that you've forwarded the service port to your local port `8080`.

```bash
kubectl port-forward security-attributes-provider 8080:8080

curl --location 'http://localhost:8080/participant/initialize' \
-X POST \
--header 'Authorization: Bearer <JWT_TOKEN>' \
--header 'Content-Type: application/json' \
--data-raw '{
  "organizationName" : "<my-organization>",
  "identityAttributes" : [ ]
}'
```

Then download the credentials, i.e. the **keystore**, from `user-roles`. Since this is an internal endpoint, you'll need to set up a port forward on the microservice to access it. In this example, we assume that you've forwarded the service port to your local port `8080`.

```bash
kubectl port-forward users-roles 8080:8080

curl --location 'http://localhost:8080/credential/download' \
-o keystore-tls-gateway.p12
```

#####  Get the TLS Gateway truststore

Authorities can download the truststore, i.e. OnBoardingCa.jks, from EJBCA Admin dashboard, as done similarly [here](/doc/EJBCA.md#download-the-managementca-certificate). Participants can extract it from the keystore with the following commands.

<!-- # specify `-legacy` since OpenSSL 3.0.x no longer supports 'legacy' algorithms like the deliberately weak RC2-40 traditionally used for PKCS12 -->
```shell
# Extract certificate from keystore
openssl pkcs12 \
-in keystore-tls-gateway.p12 \
-legacy \
-cacerts \
-nokeys \
-out OnBoardingCA-cert.pem \
-passin pass:< keystore password >

# Convert .pem to .p12
keytool -importcert \
-keystore OnBoardingCA-cert.p12 \
-storepass < keystore password > \
-file OnBoardingCA-cert.pem \
-alias onboardingca

# Convert .p12 to .jks
keytool -importkeystore \
-srckeystore OnBoardingCA-cert.p12  \
-srcstoretype PKCS12 \
-destkeystore OnBoardingCA-cert.jks \
-srcalias onboardingca \
-destalias onboardingca \
-srcstorepass < keystore password > \
-deststorepass < keystore password >
```

##### Profile-Based Configuration


###### Profiles 
The value `global.profile` set `SPRING_PROFILES_ACTIVE`: This sets the active Spring profile. The value can be `authority` or `participant`.

  - If the global profile is set to `authority`, the following environment variables are configured:
    - The value `microservices.securityAttributesProviderUrl` set `SAP_URL`: The URL for the Security Attributes Provider (SAP) microservice.
  - If the global profile is set to `participant`, the following environment variable is configured:
    - The value `global.authorityUrl` set `CLIENT_AUTHORITY_URL`: The URL for the client authority.

#### CORS Configuration

- The value `global.cors.allowOrigin` set `CORS_ALLOWED_ORIGINS`: The allowed origins for CORS requests.
    - Default value includes: `Access-Control-Allow-Headers`, `Access-Control-Allow-Credentials`, `Access-Control-Allow-Origin`, `Access-Control-Allow-Methods`, `Keep-Alive`, `User-Agent`, `Content-Type`, `Authorization`, `Tenant`, `Channel`, `Platform`, `Set-Cookie`, `geolocation`, `x-mobility-mode`, `device`, `Cache-Control`, `X-Request-With`, `Accept`, `Origin`.

##### SSL Configuration
<!-- - `SERVER_SSL_TRUST_STORE`: The location of the truststore file. -->
<!-- - `SERVER_SSL_KEY_STORE`: The location of the keystore file. -->
- The value `ssl.keyStore.password` set `SERVER_SSL_KEY_STORE_PASSWORD`: The password for the keystore.
- The value `ssl.trustStore.password` set `SERVER_SSL_TRUST_STORE_PASSWORD`: The password for the truststore.







### Step 2: Deploy the Application Using Helm Charts

Once the YAML configuration files have been updated, the next step is to deploy the application using Helm charts. Helm is a package manager for Kubernetes, allowing you to manage and deploy Kubernetes applications efficiently.

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
