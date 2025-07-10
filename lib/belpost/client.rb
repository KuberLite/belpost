# frozen_string_literal: true

require_relative "api_service"
require_relative "models/parcel"
require_relative "models/batch"
require_relative "models/batch_item"
require_relative "models/batch_status"
require_relative "models/api_response"
require_relative "validations/address_schema"
require_relative "validations/batch_schema"
require_relative "validations/batch_item_schema"
require_relative "validations/postcode_schema"
require_relative "api_paths"

module Belpost
  # Main client class for interacting with the BelPost API.
  class Client
    # Initializes a new instance of the Client.
    #
    # @raise [Belpost::Error] If JWT token is not configured.
    def initialize(logger: Logger.new($stdout))
      @config = Belpost.configuration
      raise ConfigurationError, "JWT token is required" if @config.jwt_token.nil?

      @api_service = ApiService.new(
        base_url: @config.base_url,
        jwt_token: @config.jwt_token,
        timeout: @config.timeout,
        logger: logger
      )
    end

    # Creates a new batch mailing by sending a POST request to the API.
    #
    # @param batch_data [Hash] The data for the batch mailing.
    # @return [Hash] The parsed JSON response from the API.
    # @raise [Belpost::InvalidRequestError] If the request data is invalid.
    # @raise [Belpost::ApiError] If the API returns an error response.
    def create_batch(batch_data)
      validation_result = Validation::BatchSchema.new.call(batch_data)
      raise ValidationError, "Invalid batch data: #{validation_result.errors.to_h}" unless validation_result.success?

      batch = Models::Batch.new(batch_data)
      response = @api_service.post(ApiPaths::BATCH_MAILING_LIST, batch.to_h)
      response.to_h
    end

    # Creates new items in a batch by sending a POST request to the API.
    #
    # @param batch_id [Integer] The ID of the batch where items should be added.
    # @param items_data [Hash] The data for the batch items to create.
    # @return [Hash] The parsed JSON response from the API.
    # @raise [Belpost::InvalidRequestError] If the request data is invalid.
    # @raise [Belpost::ApiError] If the API returns an error response.
    def create_batch_items(batch_id, items_data)
      raise ValidationError, "Batch ID must be provided" if batch_id.nil?
      raise ValidationError, "Batch ID must be a positive integer" unless batch_id.is_a?(Integer) && batch_id.positive?

      validation_result = Validation::BatchItemSchema.call(items_data)
      raise ValidationError, "Invalid batch item data: #{validation_result.errors.to_h}" unless validation_result.success?

      batch_item = Models::BatchItem.new(items_data)
      path = ApiPaths::BATCH_MAILING_LIST_ITEM.gsub(':id', batch_id.to_s)
      response = @api_service.post(path, batch_item.to_h)
      response.to_h
    end

    # Creates a new postal parcel by sending a POST request to the API.
    #
    # @param parcel_data [Hash] The data for the postal parcel.
    # @return [Hash] The parsed JSON response from the API.
    # @raise [Belpost::InvalidRequestError] If the request data is invalid.
    # @raise [Belpost::ApiError] If the API returns an error response.
    def create_parcel(parcel_data)
      validation_result = Validation::ParcelSchema.call(parcel_data)
      raise ValidationError, "Invalid parcel data: #{validation_result.errors.to_h}" unless validation_result.success?

      parcel = Models::Parcel.new(parcel_data)
      response = @api_service.post(ApiPaths::POSTAL_DELIVERIES, parcel.to_h)
      response.to_h
    end

    # Fetches the HS codes tree from the API.
    #
    # @return [Array<Hash>] The HS codes tree as an array of hashes.
    # @raise [Belpost::ApiError] If the API returns an error response.
    def fetch_hs_codes
      response = @api_service.get(ApiPaths::POSTAL_DELIVERIES_HS_CODES)
      response.to_h
    end

    # Fetches validation data for postal deliveries based on the country code.
    #
    # @param country_code [String] The country code (e.g. "BY", "RU-LEN").
    # @return [Hash] The parsed JSON response containing validation data.
    # @raise [Belpost::ApiError] If the API returns an error response.
    def validate_postal_delivery(country_code)
      country_code = country_code.upcase
      response = @api_service.get("#{ApiPaths::POSTAL_DELIVERIES_VALIDATION}/#{country_code}")
      response.to_h
    end

    # Allows you to get a list of countries to which postal items are sent.
    #
    # @return [Hash] The parsed JSON response containing available countries.
    # @raise [Belpost::ApiError] If the API returns an error response.
    def fetch_available_countries
      response = @api_service.get(ApiPaths::POSTAL_DELIVERIES_COUNTRIES)
      response.to_h
    end

    # Finds a batch by its ID.
    #
    # @param id [Integer] The ID of the batch to find.
    # @return [Hash] The batch data if found.
    # @raise [Belpost::ValidationError] If the ID parameter is invalid
    # @raise [Belpost::ApiError] If the API returns an error response.
    def find_batch_by_id(id)
      raise ValidationError, "ID must be provided" if id.nil?
      raise ValidationError, "ID must be a positive integer" unless id.is_a?(Integer) && id.positive?

      path = ApiPaths::BATCH_MAILING_LIST_BY_ID.gsub(':id', id.to_s)
      response = @api_service.get(path)
      response.to_h
    end

    # Allows you to find an address by a string.
    #
    # Accepts a string with an address in any form and returns found addresses (up to 50 records).
    # Building numbers should be specified without spaces: "building number""letter""building".
    # The letter should be uppercase, and "building" (or "корп", "кор", "к") should be replaced with "/".
    # Example: "город Минск улица Автодоровская 3Е корпус 4" should be transformed to "город Минск улица Автодоровская 3Е/4".
    #
    # @param address [String] The address string to search for.
    # @return [Array<Hash>] An array of found addresses with postcode, region, city, street and other information.
    # @raise [Belpost::ApiError] If the API returns an error response.
    # @raise [Belpost::InvalidRequestError] If the address parameter is missing or has an incorrect format.
    def find_address_by_string(address)
      raise ValidationError, "Address must be filled" if address.nil?
      raise ValidationError, "Address must be a string" unless address.is_a?(String)
      raise ValidationError, "Address must be filled" if address.empty?

      formatted_address = format_address(address)
      response = @api_service.get(ApiPaths::POSTCODES_AUTOCOMPLETE, { search: formatted_address })
      response.to_h
    end

    # Searches for addresses belonging to a specific postal code (postcode).
    #
    # @param postcode [String] The postal code to search for (6 digits)
    # @return [Array<Hash>] An array of addresses belonging to the specified postal code
    # @raise [Belpost::ValidationError] If the postcode is invalid
    # @raise [Belpost::ApiError] If the API returns an error response
    def find_addresses_by_postcode(postcode)
      validation_result = Validation::PostcodeSchema.new.call(postcode: postcode)
      raise ValidationError, "Invalid postcode: #{validation_result.errors.to_h}" unless validation_result.success?

      response = @api_service.get(ApiPaths::GEO_DIRECTORY_ADDRESSES, { postcode: postcode })
      response.to_h
    end

    # Searches for postal codes by city, street, and building number.
    #
    # @param city [String] The city name (required)
    # @param street [String] The street name (required)
    # @param building [String] The building number (optional)
    # @param limit [Integer] Maximum number of results (optional, default: 50, range: 1-200)
    # @return [Array<Hash>] An array of found addresses with postcode, region, city, street and other information
    # @raise [Belpost::ValidationError] If required parameters are missing or invalid
    # @raise [Belpost::ApiError] If the API returns an error response
    def search_postcode(city:, street:, building: nil, limit: 50)
      raise ValidationError, "City must be filled" if city.nil?
      raise ValidationError, "City must be a string" unless city.is_a?(String)
      raise ValidationError, "City must be filled" if city.empty?
      raise ValidationError, "Street must be filled" if street.nil?
      raise ValidationError, "Street must be a string" unless street.is_a?(String)
      raise ValidationError, "Street must be filled" if street.empty?
      raise ValidationError, "Building must be a string" if building && !building.is_a?(String)
      raise ValidationError, "Limit must be between 1 and 200" if limit < 1 || limit > 200

      params = { city: city, street: street }
      params[:building] = format_building_number(building) if building
      params[:limit] = limit

      response = @api_service.get(ApiPaths::GEO_DIRECTORY_POSTCODE, params)
      response.to_h
    end

    # Lists all batches with optional filtering.
    #
    # @param page [Integer] The page number for pagination (optional, default: 1, must be > 0)
    # @param status [String] Filter by status: 'committed' or 'uncommitted' (optional)
    # @param per_page [Integer] Number of items per page (optional)
    # @param search [Integer] Search by batch number (optional)
    # @return [Hash] The parsed JSON response containing batch list with pagination details
    # @raise [Belpost::ValidationError] If   parameters are invalid
    # @raise [Belpost::ApiError] If the API returns an error response
    def list_batches(page: 1, status: nil, per_page: nil, search: nil)
      params = {}

      # Validate page parameter
      if page
        raise ValidationError, "Page must be an integer" unless page.is_a?(Integer)
        raise ValidationError, "Page must be greater than 0" unless page.positive?

        params[:page] = page
      end

      # Validate status parameter
      if status
        unless Models::BatchStatus.valid?(status)
          raise ValidationError, "Status must be 'committed' or 'uncommitted'"
        end

        params[:status] = status
      end

      # Validate per_page parameter
      if per_page
        raise ValidationError, "Per page must be an integer" unless per_page.is_a?(Integer)
        raise ValidationError, "Per page must be positive" unless per_page.positive?

        params[:perPage] = per_page
      end

      # Validate search parameter
      if search
        raise ValidationError, "Search must be an integer" unless search.is_a?(Integer)

        params[:search] = search
      end

      response = @api_service.get(ApiPaths::BATCH_MAILING_LIST, params)
      response.to_h
    end

    # Generates address labels for a batch mailing.
    #
    # This method allows generating address labels for shipments within a batch.
    # Labels can only be generated for batches with the "In processing" status.
    # When this request is made, all address labels for shipments within the batch will be regenerated.
    # Label generation is available if the batch has the "has_documents_label" flag set to false.
    #
    # If the batch has the "is_partial_receipt" flag set to true and contains shipments with attachments,
    # a PS112e form with attachment descriptions will be included in the response ZIP archive.
    #
    # If the batch has the "is_partial_receipt" flag set to true and contains shipments without attachments,
    # address labels will not be generated for those shipments. Adding attachments to a shipment is mandatory
    # for generating address labels in this case.
    #
    # @param batch_id [Integer] The ID of the batch to generate labels for
    # @return [Hash] The parsed JSON response containing document information
    # @raise [Belpost::ValidationError] If the batch_id parameter is invalid
    # @raise [Belpost::ApiError] If the API returns an error response
    def generate_batch_blanks(batch_id)
      raise ValidationError, "Batch ID must be provided" if batch_id.nil?
      raise ValidationError, "Batch ID must be a positive integer" unless batch_id.is_a?(Integer) && batch_id.positive?

      path = ApiPaths::BATCH_MAILING_GENERATE_BLANK.gsub(':id', batch_id.to_s)
      response = @api_service.post(path, {})
      response.to_h
    end

    # Commits a batch mailing by its ID, changing status from "uncommitted" to "committed".
    #
    # This method can only commit a batch that is currently uncommitted, has items and 
    # includes contents if the batch has "is_partial_receipt" flag set to true.
    #
    # @param batch_id [Integer] The ID of the batch to commit
    # @return [Hash] The committed batch data with updated status
    # @raise [Belpost::ValidationError] If the batch_id parameter is invalid
    # @raise [Belpost::ApiError] If the API returns an error response
    def commit_batch(batch_id)
      raise ValidationError, "Batch ID must be provided" if batch_id.nil?
      raise ValidationError, "Batch ID must be a positive integer" unless batch_id.is_a?(Integer) && batch_id.positive?

      path = ApiPaths::BATCH_MAILING_COMMIT.gsub(':id', batch_id.to_s)
      response = @api_service.post(path, {})
      response.to_h
    end

    # Downloads batch mailing documents as a ZIP archive.
    #
    # This method retrieves a ZIP archive containing all documents related to a batch mailing.
    # The response contains binary data that can be saved as a ZIP file.
    #
    # @param document_id [Integer] The ID of the document to download
    # @return [Hash] Hash containing binary data, status code and headers
    # @raise [Belpost::ValidationError] If the document_id parameter is invalid
    # @raise [Belpost::ApiError] If the API returns an error response
    def download_batch_documents(document_id)
      raise ValidationError, "Document ID must be provided" if document_id.nil?
      raise ValidationError, "Document ID must be a positive integer" unless document_id.is_a?(Integer) && document_id.positive?

      path = ApiPaths::BATCH_MAILING_DOCUMENTS_DOWNLOAD.gsub(':id', document_id.to_s)
      response = @api_service.get_binary(path)
      
      # Ensure we have the correct content type for a ZIP file
      content_type = response[:headers]["content-type"]&.first
      unless content_type && content_type.include?("application/zip")
        @logger.warn("Expected ZIP file but got content type: #{content_type}")
      end
      
      response
    end

    # Translates a batch status code to its Russian translation
    #
    # @param status [String] The status code ('uncommitted' or 'committed')
    # @return [String] The Russian translation or the original status if not found
    def translate_batch_status(status)
      Models::BatchStatus.translate(status)
    end

    private

    def format_address(address)
      address.gsub(/\s+/, " ")
             .gsub(/\s*корпус\s*(\d+)\s*/i, '/\1')
             .gsub(/\s*корп\s*(\d+)\s*/i, '/\1')
             .gsub(/\s*кор\s*(\d+)\s*/i, '/\1')
             .gsub(/\s*к\s*(\d+)\s*/i, '/\1')
             .strip
    end

    def format_building_number(building)
      return building unless building

      building.gsub(/\s+/, " ")
              .gsub(/\s*корпус\s*(\d+)\s*/i, '/\1')
              .gsub(/\s*корп\s*(\d+)\s*/i, '/\1')
              .gsub(/\s*кор\s*(\d+)\s*/i, '/\1')
              .gsub(/\s*к\s*(\d+)\s*/i, '/\1')
              .strip
    end
  end
end
