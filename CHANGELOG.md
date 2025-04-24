## [0.12.1] - 2025-04-24
### Added
- Added Russian translations for batch statuses:
  - 'uncommitted' -> 'В обработке' (in processing)
  - 'committed' -> 'Сформирована' (formed)
- New `BatchStatus` class for working with batch status values
- Added `translate_batch_status` method for translating batch status values

## [0.12.0] - 2025-04-24
### Added
- Added support for downloading batch mailing documents as ZIP archives via `download_batch_documents` method
- New `get_binary` method in ApiService to handle binary data downloads

## [0.11.2] - 2025-04-24
### Added
- Added support for generating address labels for batch mailings via `generate_batch_blanks` method
- Support for generating address labels for shipments within batches with "In processing" status
- Generation of PS112e form for batches with "is_partial_receipt" flag set to true that contain shipments with attachments

## [0.11.1] - 2025-04-24
### Changed
- Enhanced validation for batch item schema to allow empty strings for `cash_on_delivery` and `declared_value` fields
- Improved flexibility in the validation of numeric fields to support both positive numeric values and empty strings

## [0.11.0] - 2025-04-23
### Added
- Added support for finding addresses by postal code via `find_addresses_by_postcode` method
- Added new validation schema for postal codes
- Added comprehensive tests for the new endpoint

## [0.9.3] - 2025-04-18
### Added
- A new `list_batches` method in the Client class that:
  - Supports pagination with the page parameter
  - Allows filtering by batch status (committed or uncommitted)
  - Enables limiting results per page with the per_page parameter
  - Provides search functionality by batch number

## [0.9.2] - 2025-04-17
### Added
- Added support for ecommerce-specific parameters:
  - `negotiated_rate`
  - `is_declared_value`
  - `is_partial_receipt`
  - `postal_items_in_ops`

## [0.9.1] - 2025-04-16
### Added
- New `PostalDeliveryTypes` module for centralized management of postal delivery types
- Tests for the `PostalDeliveryTypes` module

## [0.9.0] - 2025-04-15
### Changed
- Refactored API paths into a separate module `Belpost::ApiPaths` for better maintainability
- Moved all hardcoded API endpoints into constants in `api_paths.rb`
- Updated all client methods to use the new API path constants
- Updated tests to use the new API path constants

### Added
- Added batch retrieval functionality via `find_batch_by_id` method
- Support for finding batch mailings by their ID with validation
- New module `Belpost::ApiPaths` with organized API endpoint constants:
  - Batch mailing paths
  - Postal deliveries paths
  - Geo directory paths

## [0.8.0] - 2025-04-14
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
