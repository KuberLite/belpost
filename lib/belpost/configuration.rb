# frozen_string_literal: true

module Belpost
  # Class for managing the Belpochta API configuration.
  # Allows you to set basic parameters such as API URL, JWT token, and request timeout.
  class Configuration
    attr_accessor :base_url, :jwt_token, :timeout

    def initialize
      @base_url = ENV.fetch("BELPOST_API_URL", nil)
      @jwt_token = ENV.fetch("BELPOST_JWT_TOKEN", nil)
      @timeout = 10
    end
  end
end
