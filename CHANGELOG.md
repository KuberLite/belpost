# Changelog

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
