- In application config remove infrastructure catalogue, leave only data catalogue
- Postgresql deployment of catalogue needs to be made optional and changed via parameter
    ```yaml
    postgresql:
      enabled: false
    ```
- We need to publish the routes for the data catalogue to the tls gateway

```yaml
    springRoutes:
        - id: fc-service
        uri: "https://xfsc-data-service.{{ .Values.cluster.namespace }}.svc.cluster.local:8081"
        predicates:
            - Path=/fc/**
        filters:
            - StripPrefix=1

        - id: adapter-service
        uri: "https://adapter.{{ .Values.cluster.namespace }}.svc.cluster.local:8084"
        predicates:
            - Path=/adapter/**
        filters:
            - StripPrefix=1
    routes:
        publicUrls:
            rbac:
                - method: ALL ?!
                    path: "/fc/**"
                    disableEphemeralProofCheck: true

                - method: ALL ?!
                    path: "/adapter/**"
                    disableEphemeralProofCheck: true
    ```

- We need to create user and database for Data service in postgresql init script in values file
- Need to configure said URL and password in VAULT as required by xsfc-catalogue