# frozen_string_literal: true

module Belpost
  # Class for managing the Belpochta API configuration.
  # Allows you to set basic parameters such as API URL, JWT token, and request timeout.
  class Configuration
    attr_accessor :base_url, :jwt_token, :timeout

    def initialize
      @base_url = ENV.fetch("BELPOST_API_URL", "https://api.belpost.by")
      @jwt_token = ENV.fetch("BELPOST_JWT_TOKEN", nil)

      # Convert timeout to integer with a fallback to default
      begin
        @timeout = Integer(ENV.fetch("BELPOST_TIMEOUT", 10))
      rescue ArgumentError
        @timeout = 10
      end
    end

    # Validates that all required configuration is present
    # @raise [Belpost::ConfigurationError] If required configuration is missing
    def validate!
      raise ConfigurationError, "Base URL is required" if base_url.nil?
      raise ConfigurationError, "JWT token is required" if jwt_token.nil?
    end

    # Returns a hash representation of the configuration
    # @return [Hash] The configuration as a hash
    def to_h
      {
        base_url: base_url,
        jwt_token: jwt_token,
        timeout: timeout
      }
    end
  end
end
