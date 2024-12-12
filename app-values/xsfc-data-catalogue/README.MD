

### Values that need to be in VAULT


```yaml

  - name: FEDERATED-CATALOGUE_VERIFICATION_REQUIRE-VP
    value: "false"
  - name: FEDERATED-CATALOGUE_VERIFICATION_VP-SIGNATURE
    value: "false"
  - name: FEDERATED-CATALOGUE_VERIFICATION_VC-SIGNATURE
    value: "false"
  - name: DATASTORE_FILE_PATH
    value: /var/lib/fc-service/filestore
  - name: FEDERATED_CATALOGUE_VERIFICATION_SIGNATURES
    value: "true"
  - name: GRAPHSTORE_URI
    value: bolt://fc-neo4j:7687
  - name: GRAPHSTORE_QUERY_TIMEOUT_IN_SECONDS
    value: "5"
  - name: GRAPHSTORE_PASSWORD
    value: neo12345

  - name: KEYCLOAK_AUTH_SERVER_URL
    value: http://fc-keycloak-headless.fed-cat.svc.cluster.local:8080
  - name: KEYCLOAK_CREDENTIALS_SECRET
    valueFrom:
      secretKeyRef:
        name: fc-keycloak-client-secret
        key: keycloak_client_secret   
  - name: SPRING_DATASOURCE_URL
    value: jdbc:postgresql://fc-postgres:5432/postgres
  - name: SPRING_DATASOURCE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: fc-postgres
        key: postgres-password
  - name: SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI
    value: https://key-server.dev.simpl-europe.eu/realms/gaia-x

```