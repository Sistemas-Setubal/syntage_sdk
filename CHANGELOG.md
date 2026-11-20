# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-11-20

### Added

- `SyntageSdk.bil` resource with `list` and `retrieve` for BIL reports, including
  `id_lt` / `id_gt` cursor filters and client-side validation of `items_per_page`
  (1 to 100).

## [0.1.0] - 2026-07-01

### Added

- Initial SDK: configuration, HTTP client with retry/error handling, and
  resources covering Entities, Credentials, Events, Insights, Invoices,
  Payments, Tax compliance, Schedulers, Exports, Files, Webhooks, and more.

[Unreleased]: https://github.com/Sistemas-Setubal/syntage_sdk/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/Sistemas-Setubal/syntage_sdk/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/Sistemas-Setubal/syntage_sdk/releases/tag/v0.1.0
