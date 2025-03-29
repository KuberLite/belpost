# frozen_string_literal: true

require_relative "belpost/api_service"

module Belpost
  # Main client class for interacting with the BelPost API.
  class Client
    # Initializes a new instance of the Client.
    #
    # @raise [Belpost::Error] If JWT token is not configured.
    def initialize
      @config = Belpost.configuration
      raise Error, "JWT token is required" if @config.jwt_token.nil?

      @api_service = ApiService.new(
        base_url: @config.base_url,
        jwt_token: @config.jwt_token,
        timeout: @config.timeout
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
        raise InvalidRequestError, "Invalid request data: #{validation_result.errors.to_h}"
      end

      @api_service.post("/api/v1/business/postal-deliveries", parcel_data)
    end

    # Fetches the HS codes tree from the API.
    #
    # @return [Array<Hash>] The HS codes tree as an array of hashes.
    # @raise [Belpost::ApiError] If the API returns an error response.
    def fetch_hs_codes
      @api_service.get("/api/v1/business/postal-deliveries/hs-codes/list")
    end

    # Fetches validation data for postal deliveries based on the country code.
    #
    # @param country_code [String] The country code (e.g., "BY", "RU-LEN").
    # @return [Hash] The parsed JSON response containing validation data.
    # @raise [Belpost::ApiError] If the API returns an error response.
    def validate_postal_delivery(country_code)
      country_code = country_code.upcase

      @api_service.get("/api/v1/business/postal-deliveries/validation/#{country_code}")
    end
  end
end
