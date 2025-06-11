# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-06-06
- Updated many components to implement Governance Authority version 2.0.0.


### Onboarding

#### 1.5.0 (2025-05-12)

#### Added
- SIMPL-12213 Licenses files in the repositories
- SIMPL-7929 
- SIMPL-7928

#### Changed
- Add invoke Security Attributes provider directly for identity attributes assignment
- SIMPL-11639

#### Fixed
- Validation Rule update now update correctly also the document template linked to the rule
- Remarks are deleted when a document is uploaded again 
- SIMPL-11951 
- During creation of an onboarding request, only valid validation rules are linked to the request 
- When fault rules evaluation is triggered, the status of the rule is changed to IN_PROGRESS
- SIMPL-11639


### Users Roles

#### 1.5.0 (2025-05-12)

#### Added
- SIMPL-12213 Licenses files in the repositories


### Simpl Cloud gateway (Tier 1)

#### 1.5.0 (2025-05-12)

#### Added
- SIMPL-12213 Licenses files in the repositories


### Security Attributes Provider

#### 1.5.0 (2025-05-12)

#### Added
- SIMPL-12213 Licenses files in the repositories

#### Changed
- SIMPL-11472


### TLS Gateway (Tier 2)

#### 1.5.0 (2025-05-12)

#### Added
- SIMPL-12213 Licenses files in the repositories


### SIMPL FE

#### 1.5.3 (2025-05-15)
No changes.

#### 1.5.2 (2025-05-14)

#### Fixed
- fixed data to send for assign and unassign, change simple array of string in array of type id

#### 1.5.1 (2025-05-13)

#### Fixed
- fixed update table information after approve
- use the participantId
-
#### Changed
- label changed

#### 1.5.0 (2025-05-12)

#### Added
- SIMPL-10556
- SIMPL-10979
- SIMPL-8226
- SIMPL-10558


### Identity Provider

#### 1.5.0 (2025-05-12)

#### Added
- SIMPL-12213 Licenses files in the repositories
- Added simpl.proof-or-possession property tree

#### Changed
- Changed POST /participants that now doesn't accept identityAttributes attribute
- SIMPL-10873


### Authentication Provider

#### 1.5.0 (2025-05-12)

#### Added
- SIMPL-12213 Licenses files in the repositories

#### Changed
- SIMPL-12042


### xsfc-catalogue

#### 1.0.7 (2025-05-12)
No changes.


### catalogue query mapper adapter

#### 1.0.6 (2025-05-05)

#### Changed
- SIMPL-4449 Fix sonar


### Filebeat

#### 0.1.14 (2025-05-12)

#### Changed
- SIMPL-12666 Remove unused fields
