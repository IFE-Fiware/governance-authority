# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.4.0] - 2025-11-15
- Updated many components to implement Consumer version 2.4.0.

## [2.3.3] - 2025-10-31

- Replaced Vault by OpenBao
- Update ejbca-preconfig to version 1.0.3

## [2.3.2] - 2025-10-30

- Update monitoring stack to version 0.1.20

## [2.3.1] - 2025-10-15

- adjustments to the readme file

## [2.3.0] - 2025-10-10

- Updated many components to implement Consumer version 2.3.0.
- Add component Redis.
- Add component Tier2-Proxy.

### Onboarding

#### 2.5.0 (2025-09-29)

#### Changed
- SIMPL-14571
- 
#### Fixed
- SIMPL-6964
#### 2.4.0 (2025-09-08)

#### Added

- SIMPL-14971

#### Changed

- SIMPL-13017

#### Fixed

- SIMPL-11639
- SIMPL-14765
- SIMPL-11828

### Simpl Cloud gateway (Tier 1)

#### 2.5.0 (2025-09-29)

#### Added
- Added new routes for Security Attributes Provider

#### Fixed
- Https constraints applied in Content Security Policy only when https origins are present
#### 2.4.0 (2025-09-08)

#### Added

- SIMPL-14971

#### Changed

- SIMPL-15701

### Users Roles

#### 2.5.1 (2025-10-16)

#### Fixed
- Identity Attributes validation now handles correctly identity attributes not assigned to participant, not assignable to roles and disabled.

#### 2.5.0 (2025-09-29)

#### Fixed
- SIMPL-12860
- SIMPL-16081
#### 2.4.0 (2025-09-08)

#### Added

- SIMPL-14971

#### Fixed

- SIMPL-16771

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
#### 2.4.0 (2025-09-08)

#### Added

- SIMPL-15662
- SIMPL-15665
- SIMPL-12865
- SIMPL-15656
- SIMPL-15655

#### Fixed

- SIMPL-15726
- SIMPL-16121
- SIMPL-15909
- SIMPL-15909

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
#### 2.4.0 (2025-09-08)

#### Added

- SIMPL-14971

#### Fixed

- SIMPL-10191

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
#### 2.4.2 (2025-09-26)

#### Fixed

- Identity Attributes of local copy get creationTimestamp and updateTimestamp from authority synchronization flow
- SIMPL-13018

#### 2.4.1 (2025-09-18)

No changes.

#### 2.4.0 (2025-09-08)

#### Added

- Added unique constraint on private_key.keypair_id column
- SIMPL-14971
- SIMPL-12990

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
#### 2.4.0 (2025-09-08)

#### Added

- SIMPL-14971

#### Changed

- SIMPL-15701

### Security Attributes Provider

#### 2.5.1 (2025-10-07)

#### Fixed
- Fixed Time To Live computation for SignatureProof when managing nanos

#### 2.5.0 (2025-09-29)

#### Added
- Implemented v2 endpoints

#### Fixed
- SIMPL-14604
#### 2.4.0 (2025-09-08)

#### Added

- SIMPL-14971

#### Changed

- Update ephemeral-proof expiration to 3 minutes

### xsfc-catalogue

#### 1.0.11 (2025-09-05)

#### Added
- SIMPL-11277

#### Changed
- SIMPL-17539
- SIMPL-5947

#### Added

- SIMPL-11277

#### Changed

- SIMPL-17539
- SIMPL-5947

### catalogue query mapper adapter

#### 1.0.13 (2025-09-08)

#### Added
- SIMPL-11277

- SIMPL-11277

### Filebeat

#### 0.1.19 (2025-09-26)

#### Fixed
- SIMPL-18667 Fix cluster health alert

#### Changed
- SIMPL-18665 Create ILM policy for filebeat
#### 0.1.18 (2025-09-04)

No changes.
