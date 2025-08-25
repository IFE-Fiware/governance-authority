# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.2] - 2025-08-22
- Extend resource limits for Identity Provider, Onboarding and FC-Catalogue 

## [2.1.1] - 2025-07-30
- hotfix to tier1 gateway config (added NOTARY role to some paths)

## [2.1.0] - 2025-06-27
- Updated many components to implement Governance Authority version 2.1.0.
- Remove component simpl-cli


### Onboarding

#### 2.0.0 (2025-06-03)

#### Added
- Maven goal to automatically add openapi from simpl-api-iaa 
- Added POST /onboardingProcedureTemplates
- SIMPL-12206
- Add FK constraints from onboarding_template and onboarding_request to participant_type.id
- Added Configuration Properties section
- Added the API Documentation section

#### Changed
- Declared url of validation endpoint for a content check validation rule can... 
- Removed ingress spec from chart
- Removed request body from /onboardingRequests/{onboardingRequestId}/approve
- Removed property auto-approval.identity-attributes-from-sap

#### Fixed
- Validation rule can't be created if declared document template isn't bound to...
- OnboardingProcedureTemplate is fetched by it id instead of participantTypeId
- RuleName attribute correctly valued in remarks for presence check rules and... 


## Simpl Cloud gateway (Tier 1)

#### 2.0.0 (2025-06-03)

#### Added
- Added Configuration Properties section
- Added the API Documentation section (merge request)


### Users Roles

#### 2.0.0 (2025-06-03)

#### Added
- Drop table identity attribute
- Added Configuration Properties section
- Added API Documentation section
- Maven goal to automatically add openapi from simpl-api-iaa
- Search roles by multiple names

#### Changed
- Removed deprecated API
- Removed ingress spec from chart
- Removed keycloak.client-to-realm-role-migration properties
- SIMPL-11765 Remove version v0 APIs fom IAA components


### SIMPL FE

#### 2.0.1 (2025-06-05)

#### Changed
- Fixed the display of assigned identity attributes and those for the user

#### 2.0.0 (2025-06-03)

#### Added
- SIMPL-10530
- SIMPL-10533
- SIMPL-11766
- SIMPL-8228
- SIMPL-8227

#### Changed
- SIMPL-8338


### TLS Gateway (Tier 2)

#### 2.0.0 (2025-06-03)
No changes.


### Authentication Provider

#### 2.0.0 (2025-06-03)

#### Added
- Maven goal to automatically add openapi from simpl-api-iaa
- SIMPL-12367 Integrate the reviewed APIs into the Keycloak Authenticator extension
- Added Configuration Properties section
- Added the API Documentation section

#### Changed
- Removed microservice.users-roles.url property
- Removed deprecated API
- CredentialInitializerImpl
- Removed ingress spec from chart
- SIMPL-11765 Remove version v0 APIs fom IAA components


### Identity Provider

#### 2.0.0 (2025-06-03)

#### Added
- Maven goal to automatically add openapi from simpl-api-iaa
- SIMPL-12357
- Added Configuration Properties section
- Created the README.md file

#### Changed
- Removed dependency from onboarding
- Removed microservice.users-roles.url property
- Removed deprecated API
- Removed ingress spec from chart
- Removed table certificate from data model
- SIMPL-11765

#### Fixed
- SIMPL-12644


### Security Attributes Provider

#### 2.0.0 (2025-06-03)

#### Added
- Added Configuration Properties section
- Added README.md
- Maven goal to automatically add openapi from simpl-api-iaa

#### Changed
- Removed microservice.onboarding.url property
- Removed ingress spec from chart
- Removed deprecated endpoints
- Removed identity_attribute_participant_type table from db
- SIMPL-11765


### xsfc-catalogue

#### 1.0.7 (2025-05-12)
No changes.


### catalogue query mapper adapter

#### 1.0.9 (2025-06-23)

#### Added
- SIMPL-4447 added interfaces for services

#### Changed
- SIMPL-13497
- SIMPL-12683
- SIMPL-10754
- SIMPL-12683
- SIMPL-4447
- SIMPL-12683


### Filebeat

#### 0.1.15 (2025-06-05)

#### Changed
- Edited dashboard for heartbeat
- SIMPL-13099
- SIMPL-12666 Removed unused fields
- Changed configuration because of change in business pods names.
- SIMPL-12666 Remove unused fields
