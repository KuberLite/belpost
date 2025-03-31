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
    # @return [Models::ApiResponse] The parsed JSON response from the API.
    def get(path)
      Retry.with_retry do
        uri = URI("#{@base_url}#{path}")
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

    def handle_response(response)
      case response.code
      when "200"
        response
      when "401", "403"
        raise AuthenticationError.new(
          "Authentication failed",
          status_code: response.code.to_i,
          response_body: response.body
        )
      when "429"
        raise RateLimitError.new(
          "Rate limit exceeded",
          status_code: response.code.to_i,
          response_body: response.body
        )
      when "400"
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

    def log_request(request)
      @logger.info("Making #{request.method} request to #{request.uri}")
      @logger.debug("Request headers: #{request.to_hash}")
      @logger.debug("Request body: #{request.body}") if request.body
    end

    def log_response(response)
      @logger.info("Received response with status #{response.code}")
      @logger.debug("Response headers: #{response.to_hash}")
      @logger.debug("Response body: #{response.body}")
    end
  end
end
