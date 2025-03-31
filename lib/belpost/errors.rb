# frozen_string_literal: true

module Belpost
  class Error < StandardError; end

  class ConfigurationError < Error; end

  class ApiError < Error
    attr_reader :status_code, :response_body

    def initialize(message, status_code: nil, response_body: nil)
      @status_code = status_code
      @response_body = response_body
      super(message)
    end
  end

  class AuthenticationError < ApiError; end
  class InvalidRequestError < ApiError; end
  class RateLimitError < ApiError; end
  class ServerError < ApiError; end
  class NetworkError < Error; end
  class TimeoutError < Error; end
  class ValidationError < Error; end
end
