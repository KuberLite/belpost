# frozen_string_literal: true

module Belpost
  # Constants for API paths
  module ApiPaths
    # Batch mailing paths
    BATCH_MAILING_LIST = "/api/v1/business/batch-mailing/list"
    BATCH_MAILING_DOCUMENTS = "/api/v1/business/batch-mailing/documents"
    BATCH_MAILING_ITEM = "/api/v1/business/batch-mailing/item"
    BATCH_MAILING_DUPLICATE = "/api/v1/business/batch-mailing/list/:id/duplicate"
    BATCH_MAILING_DUPLICATE_FULL = "/api/v1/business/batch-mailing/list/:id/duplicate-full"
    BATCH_MAILING_COMMIT = "/api/v1/business/batch-mailing/list/:id/commit"
    BATCH_MAILING_GENERATE_BLANK = "/api/v1/business/batch-mailing/list/:id/generate-blank"

    # Postal deliveries paths
    POSTAL_DELIVERIES = "/api/v1/business/postal-deliveries"
    POSTAL_DELIVERIES_HS_CODES = "/api/v1/business/postal-deliveries/hs-codes/list"
    POSTAL_DELIVERIES_VALIDATION = "/api/v1/business/postal-deliveries/validation"
    POSTAL_DELIVERIES_COUNTRIES = "/api/v1/business/postal-deliveries/countries"

    # Geo directory paths
    GEO_DIRECTORY_SEARCH_ADDRESS = "/api/v1/business/geo-directory/search-address"
    GEO_DIRECTORY_POSTCODE = "/api/v1/business/geo-directory/postcode"
  end
end 