# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.4.0] - 2025-11-15
- Updated many components to implement Consumer version 2.4.0.


### Onboarding

#### 2.5.0 (2025-09-29)

#### Changed
- SIMPL-14571
- 
#### Fixed
- SIMPL-6964


### Simpl Cloud gateway (Tier 1)

#### 2.5.0 (2025-09-29)

#### Added
- Added new routes for Security Attributes Provider

#### Fixed
- Https constraints applied in Content Security Policy only when https origins are present


### Users Roles

#### 2.5.1 (2025-10-16)

#### Fixed
- Identity Attributes validation now handles correctly identity attributes not assigned to participant, not assignable to roles and disabled.

#### 2.5.0 (2025-09-29)

#### Fixed
- SIMPL-12860
- SIMPL-16081


### SIMPL FE

#### 2.5.0 (2025-09-29)

#### Added
- SIMPL-14573
- SIMPL-16741
- SIMPL-16738
- SIMPL-16739
- SIMPL-16740

#### Fixed
- SIMPL-16738


### TLS Gateway (Tier 2)

#### 2.5.0 (2025-09-29)

#### Added
- Added new routes for Security Attributes Provider

#### Fixed
- SIMPL-14604


### Tier 2 Proxy

#### 1.0.1 (2025-08-06)

#### Fixed
- Fixed base docker image


### Authentication Provider

#### 2.5.2 (2025-10-17)

#### Fixed
- Removed bitnami legacy image from helm chart

#### 2.5.1 (2025-10-07)

#### Fixed
- Attempt identity attributes update after storing the ephemeral proof
- Avoid storing already expired ephemeral proofs

#### 2.5.0 (2025-09-29)

#### Added
- SIMPL-17522
- SIMPL-17529
- SIMPL-17530
- SIMPL-17492
- SIMPL-17517
- SIMPL-17516

#### Fixed
- SIMPL-16621


### Identity Provider

#### 2.5.2 (2025-10-07)

#### Fixed
- Fix applicant role check in ParticipantServiceImpl

#### 2.5.1 (2025-10-01)

#### Fixed
- Fixed mapping from DTO to ParticipantService.CreateParticipantArgs.V2

#### 2.5.0 (2025-09-29)

#### Fixed
- SIMPL-17516
- SIMPL-17496
- SIMPL-17495

#### Fixed
- SIMPL-12640


### Security Attributes Provider

#### 2.5.1 (2025-10-07)

#### Fixed
- Fixed Time To Live computation for SignatureProof when managing nanos

#### 2.5.0 (2025-09-29)

#### Added
- Implemented v2 endpoints

#### Fixed
- SIMPL-14604


### xsfc-catalogue

#### 1.0.11 (2025-09-05)

#### Added
- SIMPL-11277

#### Changed
- SIMPL-17539
- SIMPL-5947


### catalogue query mapper adapter

#### 1.0.13 (2025-09-08)

#### Added
- SIMPL-11277


### Filebeat

#### 0.1.19 (2025-09-26)

#### Fixed
- SIMPL-18667 Fix cluster health alert

#### Changed
- SIMPL-18665 Create ILM policy for filebeat
