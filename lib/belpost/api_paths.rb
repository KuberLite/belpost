# frozen_string_literal: true

module Belpost
  # Constants for API paths
  module ApiPaths
    # Batch mailing paths
    BATCH_MAILING_LIST = "/api/v1/business/batch-mailing/list"
    BATCH_MAILING_LIST_BY_ID = "/api/v1/business/batch-mailing/list/:id"
    BATCH_MAILING_DOCUMENTS = "/api/v1/business/batch-mailing/documents"
    BATCH_MAILING_DUPLICATE = "/api/v1/business/batch-mailing/list/:id/duplicate"
    BATCH_MAILING_DUPLICATE_FULL = "/api/v1/business/batch-mailing/list/:id/duplicate-full"
    BATCH_MAILING_COMMIT = "/api/v1/business/batch-mailing/list/:id/commit"
    BATCH_MAILING_GENERATE_BLANK = "/api/v1/business/batch-mailing/list/:id/generate-blank"
    BATCH_MAILING_LIST_ITEM = "/api/v1/business/batch-mailing/list/:id/item"
    BATCH_MAILING_DOCUMENTS_DOWNLOAD = "/api/v1/batch-mailing/documents/:id/download"

    # Postal deliveries paths
    POSTAL_DELIVERIES = "/api/v1/business/postal-deliveries"
    POSTAL_DELIVERIES_HS_CODES = "/api/v1/business/postal-deliveries/hs-codes/list"
    POSTAL_DELIVERIES_VALIDATION = "/api/v1/business/postal-deliveries/validation"
    POSTAL_DELIVERIES_COUNTRIES = "/api/v1/business/postal-deliveries/countries"

    # Geo directory paths
    GEO_DIRECTORY_SEARCH_ADDRESS = "/api/v1/business/geo-directory/search-address"
    GEO_DIRECTORY_POSTCODE = "/api/v1/business/geo-directory/postcode"
    GEO_DIRECTORY_ADDRESSES = "/api/v1/business/geo-directory/addresses"

    # Postcodes paths
    POSTCODES_AUTOCOMPLETE = "/api/v1/postcodes/autocomplete"
  end
end
