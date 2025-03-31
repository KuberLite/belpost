# frozen_string_literal: true

module Belpost
  # Class for managing the Belpochta API configuration.
  # Allows you to set basic parameters such as API URL, JWT token, and request timeout.
  class Configuration
    attr_accessor :base_url, :jwt_token, :timeout

    def initialize
      @base_url = ENV.fetch("BELPOST_API_URL")
      @jwt_token = ENV.fetch("BELPOST_JWT_TOKEN", nil)
      @timeout = ENV.fetch("BELPOST_TIMEOUT", 10).to_i
    end
  end
end
