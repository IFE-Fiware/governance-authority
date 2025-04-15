## 1.2.1 (2025-04-15)

No changes.


# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.1] - 2025-04-03
- Fix version of ejbca-preconfig image

## [1.2.0] - 2025-03-13
- Updated many components to implement Authority version 1.2.0.
- Implemented automatic onboarding.

## [1.1.5] - 2025-02-24

### Changed
- Added denied-urls of mtls paths in simpl-cloud-gateway

## [1.1.4] - 2025-02-13

### Changed
- Fixed Filebeat deployment
- Update readme

## [1.1.3] - 2025-02-12

### Changed
- Adjusted roles of unassign-participant and assign-participant gateway paths
- Minor fixes in readme

## [1.1.0] - 2025-01-30

### Changed
- Installation of the Governance Authority agent
- Certificate authority set-up for the DataSpace Governance Authority
- DataSpace participants end-to-end onboarding processes, including distribution of security credentials (certificates) to participants
- Central XFSC catalogue set-up, ready to be loaded, via procedures, with the DataSpace defined vocabularies/ontologies
- API gateway, secured with certificates, for participants communications with the Governance Authority for credentials exchange and catalogue publishing and search"