## 1.3.1 (2025-05-20)

No changes.


# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.1] - 2025-05-20
- Readme file fixes.
- Fixed usernames for databases.

## [1.3.0] - 2025-04-18
- Updated many components to implement Authority version 1.3.0.
- Moved Redis and PostgreSQL components to Common Agent.
- Added Notification component to Common Agent.


### Onboarding

#### 1.3.1 (2025-04-11)
No changes.

#### 1.3.0 (2025-03-31)

#### Added
- Implementation of /v1/onboardingRequests/{id}/evaluateFaultRules 
- SIMPL-10115 | Enabled kafka communication 
- SIMPL-10115 Background service deleting rejected onboarding request 
- Implemented rule execution transitions 
- Liquibase script for ValidationRule, ValidationRuleExecution and ValidationRuleExecutionRemark 
- SIMPL-10611 Test driven events and handlers for new state machine transitions 
- test driven for onboarding validation rules 
- Liquibase script for ValidationRule, ValidationRuleExecution and ValidationRuleExecutionRemark 
- SIMPL-10611 Test driven events and handlers for new state machine transitions 
- test driven for onboarding validation rules 
- test driven for onboarding validation rules 
- SIMPL-7924 Applicant submits onboarding request with validation rules for review 
- SIMPL-10611 Evaluate rule execution results to determine and update the onboarding request status

#### Changed
- Moved Onboarding to V1 Models
- Changed configuration for scheduled tasks in chart

#### Fixed
- Fix api V1 sort direction


### Users Roles

#### 1.3.1 (2025-04-11)
No changes.

#### 1.3.0 (2025-03-31)

#### Added
- Event management for deleted onboarding requests

#### Changed
- Replaced StreamingResponseBody with Resource

#### Fixed
- SIMPL-10198 Bugfix


### Simpl Cloud gateway (Tier 1)

#### 1.3.1 (2025-04-11)
No changes.

#### 1.3.0 (2025-03-31)

#### Fixed
- SIMPL-9234 BUGFIX boolean methods names


### Security Attributes Provider

#### 1.3.1 (2025-04-11)
No changes.

#### 1.3.0 (2025-03-31)

#### Changed
- Migration to /v1/ParticipantTypes API


### TLS Gateway (Tier 2)

#### 1.3.1 (2025-04-11)
No changes.

#### 1.3.0 (2025-03-31)

#### Changed
- AuthenticationProviderClient now use Exchanges to make http requests

#### Fixed
- SIMPL-9510 Bugfix on boolean method name


### SIMPL FE

#### 1.3.5 (2025-04-16)

#### Fixed
- [SIMPL-10718] - Fixed Request revision visibility for Notary
- fixed checkbox behavior, now you cannot select an identity attribute if it cannot be assigned to a role

#### 1.3.4 (2025-04-08)

#### Fixed
- fix api v1 with prefix

#### 1.3.3 (2025-04-07)

#### Fixed
- fixed rejection cause message and update info

#### 1.3.2 (2025-04-02)

#### Fixed
- fixed /authApi/v1/credentials API for multipart

#### 1.3.1 (2025-04-01)

#### Added
- added loading in echo button

#### Changed
- removed old alert banner with new EUI growl

#### Fixed
- fix endpoint API

#### 1.3.0 (2025-03-31)

#### Added
- [SIMPL-9111] - EUI Init for SAP MFE
- added auth guard
- added and configured eui for onboarding micro frontend
- [SIMPL-9111] - Refactoring Participant Type Page

#### Changed
- onboarding refactoring request status page and comment component in library
- onboarding request added eui component and restyling page
- Show and hidden password
- edit pages info page and request credentials by replacing material with eui design system (merge request)

#### Fixed
- [SIMPL-9111] - Fixed Identifier Column in Identity Attributes Page. See [SIMPL-918]


### Identity Provider

#### 1.3.1 (2025-04-11)
No changes.

#### 1.3.0 (2025-03-31)

#### Changed
- Replaced StreamingResponseBody with Resource


### Authentication Provider

#### 1.3.4 (2025-04-11)
No changes.

#### 1.3.3 (2025-04-08)

#### Fixed
- Revert CredentialId fix on MTLSController

#### 1.3.2 (2025-04-07)

#### Fixed
- Update http client version

#### 1.3.1 (2025-03-31)

#### Fixed
- CredentialId decode

#### 1.3.0 (2025-03-31)

#### Changed
- Replaced StreamingResponseBody with Resource


### xsfc-catalogue

#### 1.0.3 (2025-03-07)

#### Added
- SIMPL-10245 - Create OpenAPI based specs for simpl-fc-service 
- SIMPL-7905 - Adjust kubernetes resource settings for catalogue_connector components


### catalogue query mapper adapter

#### 1.0.3 (2025-03-11)

#### Added
- SIMPL-7905 - Adjust kubernetes resource settings for catalogue_connector components 
- SIMPL-10148 - Update Adapter Service to match API Guidelines

#### Changed
- SIMPL-10917 - Harcoded issuer in ingress of adapter
- SIMPL-8487 - PSO | Code verification: Use meaningful names for methods in FederatedCatalogueClient 
- SIMPL-10144 - Remove critical and high vulnerabilities from Fortify scan in component poc-gaia-edc


### Filebeat

#### 0.1.12 (2025-03-07)

#### Added
- Added logs parsing for new containers 
- Added end user manual for dashboards

#### Changed
- Changed default values for kibana resources

#### Fixed
- Moved changelog file to correct directory
- Upgrade ELK to 8.16.0
