# frozen_string_literal: true

require "net/http"
require "json"
require "logger"

module Belpost
  # Service class for handling HTTP requests to the BelPost API.
  class ApiService
    # Initializes a new instance of the ApiService.
    #
    # @param base_url [String] The base URL of the API.
    # @param jwt_token [String] The JWT token for authentication.
    # @param timeout [Integer] The request timeout in seconds (default: 10).
    # @param logger [Logger] The logger for logging requests and responses.
    def initialize(base_url:, jwt_token:, timeout: 10, logger: Logger.new($stdout))
      @base_url = base_url
      @jwt_token = jwt_token
      @timeout = timeout
      @logger = logger
    end

    # Performs a GET request to the specified path.
    #
    # @param path [String] The API endpoint path.
    # @param params [Hash] The query parameters (default: {}).
    # @return [Models::ApiResponse] The parsed JSON response from the API.
    def get(path, params = {})
      Retry.with_retry do
        uri = URI("#{@base_url}#{path}")
        uri.query = URI.encode_www_form(params) unless params.empty?
        request = Net::HTTP::Get.new(uri)
        add_headers(request)

        log_request(request)
        response = execute_request(uri, request)
        log_response(response)

        begin
          Models::ApiResponse.new(
            data: JSON.parse(response.body),
            status_code: response.code.to_i,
            headers: response.to_hash
          )
        rescue JSON::ParserError => e
          raise ParseError, "Failed to parse JSON response: #{e.message}"
        end
      end
    end
    
    # Performs a GET request to the specified path and returns binary data.
    #
    # @param path [String] The API endpoint path.
    # @param params [Hash] The query parameters (default: {}).
    # @return [Hash] Hash containing binary data, status code and headers
    def get_binary(path, params = {})
      Retry.with_retry do
        uri = URI("#{@base_url}#{path}")
        uri.query = URI.encode_www_form(params) unless params.empty?
        request = Net::HTTP::Get.new(uri)
        add_headers(request)
        request["Accept"] = "*/*"  # Override Accept header to receive any content type

        log_request(request)
        response = execute_request(uri, request)
        log_response(response, binary: true)

        {
          data: response.body,
          status_code: response.code.to_i,
          headers: response.to_hash
        }
      end
    end

    # Performs a POST request to the specified path with the given body.
    #
    # @param path [String] The API endpoint path.
    # @param body [Hash] The request body as a hash.
    # @return [Models::ApiResponse] The parsed JSON response from the API.
    def post(path, body)
      Retry.with_retry do
        uri = URI("#{@base_url}#{path}")
        request = Net::HTTP::Post.new(uri)
        add_headers(request)
        request.body = body.to_json

        log_request(request)
        response = execute_request(uri, request)
        log_response(response)

        begin
          Models::ApiResponse.new(
            data: JSON.parse(response.body),
            status_code: response.code.to_i,
            headers: response.to_hash
          )
        rescue JSON::ParserError => e
          raise ParseError, "Failed to parse JSON response: #{e.message}"
        end
      end
    end
    
    # Performs a PUT request to the specified path with the given body.
    #
    # @param path [String] The API endpoint path.
    # @param body [Hash] The request body as a hash.
    # @return [Models::ApiResponse] The parsed JSON response from the API.
    def put(path, body)
      Retry.with_retry do
        uri = URI("#{@base_url}#{path}")
        request = Net::HTTP::Put.new(uri)
        add_headers(request)
        request.body = body.to_json

        log_request(request)
        response = execute_request(uri, request)
        log_response(response)

        begin
          Models::ApiResponse.new(
            data: JSON.parse(response.body),
            status_code: response.code.to_i,
            headers: response.to_hash
          )
        rescue JSON::ParserError => e
          raise ParseError, "Failed to parse JSON response: #{e.message}"
        end
      end
    end
    
    # Performs a DELETE request to the specified path.
    #
    # @param path [String] The API endpoint path.
    # @return [Models::ApiResponse] The parsed JSON response from the API.
    def delete(path)
      Retry.with_retry do
        uri = URI("#{@base_url}#{path}")
        request = Net::HTTP::Delete.new(uri)
        add_headers(request)

        log_request(request)
        response = execute_request(uri, request)
        log_response(response)

        begin
          Models::ApiResponse.new(
            data: JSON.parse(response.body),
            status_code: response.code.to_i,
            headers: response.to_hash
          )
        rescue JSON::ParserError => e
          raise ParseError, "Failed to parse JSON response: #{e.message}"
        end
      end
    end

    private

    # Adds standard headers to the HTTP request.
    #
    # @param request [Net::HTTP::Request] The HTTP request object.
    def add_headers(request)
      request["Authorization"] = "Bearer #{@jwt_token}"
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"
    end

    # Executes the HTTP request and processes the response.
    #
    # @param uri [URI] The URI of the request.
    # @param request [Net::HTTP::Request] The HTTP request object.
    # @return [Net::HTTP::Response] The HTTP response object.
    # @raise [Belpost::ApiError] If the API returns an error response.
    def execute_request(uri, request)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == "https"
      http.read_timeout = @timeout
      begin
        response = http.request(request)
        handle_response(response)
      rescue Net::OpenTimeout, Net::ReadTimeout
        raise RequestError, "Request timed out after #{@timeout} seconds"
      rescue Net::HTTPError => e
        case e.response.code
        when "401", "403"
          raise AuthenticationError.new(
            "Authentication failed",
            status_code: e.response.code.to_i,
            response_body: e.response.body
          )
        when "429"
          raise RateLimitError.new(
            "Rate limit exceeded",
            status_code: e.response.code.to_i,
            response_body: e.response.body
          )
        when "400"
          raise InvalidRequestError.new(
            "Invalid request",
            status_code: e.response.code.to_i,
            response_body: e.response.body
          )
        else
          raise ServerError.new(
            "Server error",
            status_code: e.response.code.to_i,
            response_body: e.response.body
          )
        end
      rescue StandardError => e
        raise NetworkError, "Network error: #{e.message}"
      end
    end

    # Logs the HTTP request details.
    #
    # @param request [Net::HTTP::Request] The HTTP request object.
    def log_request(request)
      @logger.info("API Request: #{request.method} #{request.uri}")
      @logger.debug("Request Headers: #{request.each_header.to_h}") if request.respond_to?(:each_header)
      @logger.debug("Request Body: #{request.body}") if request.body
    end

    # Logs the HTTP response details.
    #
    # @param response [Net::HTTP::Response] The HTTP response object.
    # @param binary [Boolean] If this is a binary response (default: false).
    def log_response(response, binary: false)
      status_message = response.respond_to?(:message) ? " #{response.message}" : ""
      @logger.info("API Response: #{response.code}#{status_message}")
      
      if response.respond_to?(:each_header)
        @logger.debug("Response Headers: #{response.each_header.to_h}")
      elsif response.respond_to?(:to_hash)
        @logger.debug("Response Headers: #{response.to_hash}")
      end
      
      if binary
        @logger.debug("Response Body: [BINARY DATA]")
      else
        @logger.debug("Response Body: #{response.body}")
      end
    end

    # Handles the HTTP response.
    #
    # @param response [Net::HTTP::Response] The HTTP response object.
    # @return [Net::HTTP::Response] The HTTP response object if successful.
    # @raise [Belpost::ApiError] If the API returns an error response.
    def handle_response(response)
      case response.code.to_i
      when 200..299
        response
      when 401, 403
        raise AuthenticationError.new(
          "Authentication failed",
          status_code: response.code.to_i,
          response_body: response.body
        )
      when 429
        raise RateLimitError.new(
          "Rate limit exceeded",
          status_code: response.code.to_i,
          response_body: response.body
        )
      when 400
        raise InvalidRequestError.new(
          "Invalid request",
          status_code: response.code.to_i,
          response_body: response.body
        )
      else
        raise ServerError.new(
          "Server error",
          status_code: response.code.to_i,
          response_body: response.body
        )
      end
    end
  end
end
