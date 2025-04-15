# frozen_string_literal: true

require_relative "api_service"
require_relative "models/parcel"
require_relative "models/batch"
require_relative "models/api_response"
require_relative "validations/address_schema"
require_relative "validations/batch_schema"
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
      unless validation_result.success?
        raise ValidationError, "Invalid batch data: #{validation_result.errors.to_h}"
      end

      batch = Models::Batch.new(batch_data)
      response = @api_service.post(ApiPaths::BATCH_MAILING_LIST, batch.to_h)
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
      unless validation_result.success?
        raise ValidationError, "Invalid parcel data: #{validation_result.errors.to_h}"
      end

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
    # @raise [Belpost::ApiError] If the API returns an error response.
    def find_batch_by_id(id)
      raise ValidationError, "ID must be provided" if id.nil?
      raise ValidationError, "ID must be a positive integer" unless id.is_a?(Integer) && id.positive?

      response = @api_service.get("#{ApiPaths::BATCH_MAILING_LIST}/#{id}")
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
      response = @api_service.get(ApiPaths::GEO_DIRECTORY_SEARCH_ADDRESS, { search: formatted_address })
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
