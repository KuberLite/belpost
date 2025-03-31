# frozen_string_literal: true

require_relative "api_service"
require_relative "models/parcel"
require_relative "models/api_response"

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
      response = @api_service.post("/api/v1/business/postal-deliveries", parcel.to_h)
      response.to_h
    end

    # Fetches the HS codes tree from the API.
    #
    # @return [Array<Hash>] The HS codes tree as an array of hashes.
    # @raise [Belpost::ApiError] If the API returns an error response.
    def fetch_hs_codes
      response = @api_service.get("/api/v1/business/postal-deliveries/hs-codes/list")
      response.to_h
    end

    # Fetches validation data for postal deliveries based on the country code.
    #
    # @param country_code [String] The country code (e.g. "BY", "RU-LEN").
    # @return [Hash] The parsed JSON response containing validation data.
    # @raise [Belpost::ApiError] If the API returns an error response.
    def validate_postal_delivery(country_code)
      country_code = country_code.upcase
      response = @api_service.get("/api/v1/business/postal-deliveries/validation/#{country_code}")
      response.to_h
    end

    # Allows you to get a list of countries to which postal items are sent.
    #
    # @return [Hash] The parsed JSON response containing available countries.
    # @raise [Belpost::ApiError] If the API returns an error response.
    def fetch_available_countries
      response = @api_service.get("/api/v1/business/postal-deliveries/countries")
      response.to_h
    end
  end
end
