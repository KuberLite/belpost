# Changelog

## [0.8.0] - 2025-04-01
### Added
- Added batch mailing functionality via `create_batch` method
- Support for creating batch mailings with various delivery types
- Added comprehensive validation for batch mailing data
- Added new models and schemas for batch mailing
- Added tests for batch mailing functionality

## [0.7.0] - 2025-04-01
### Added
- Added postal code search functionality via `search_postcode` method
- Support for searching postal codes by city, street, and building number
- Added comprehensive tests for the new postal code search endpoint

## [0.6.0] - 2025-04-01
### Added
- Added search addresses search functionality via `find_address_by_string` method

## [0.5.1] - 2025-04-01
### Fixed
- Improved error handling for invalid timeout environment variable
- Added fallback for BELPOST_API_URL environment variable to make tests more robust
- Fixed Configuration class by implementing `validate!` and `to_h` methods

## [0.5.0] - 2025-04-01
### Added
- Added address search functionality via `find_address_by_string` method
- Support for query parameters in GET requests

## [0.4.0] - 2025-04-01
### Added
- Added configuration via environment variables
- Added test coverage and CI setup
- Added basic documentation in README
- Added .env.test.example for testing setup
- Added spec helper with test configuration


## [0.1.0] - 2025-03-31
### Added
- Initial gem version
- Core classes for interacting with the Belpost API
- Support for creating parcels
- Data validation before sending to API
- Error handling and request retries
