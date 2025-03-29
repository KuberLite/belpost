require "net/http"
require "json"

module Belpost
  # Service class for handling HTTP requests to the BelPost API.
  class ApiService
    # Initializes a new instance of the ApiService.
    #
    # @param base_url [String] The base URL of the API.
    # @param jwt_token [String] The JWT token for authentication.
    # @param timeout [Integer] The request timeout in seconds (default: 10).
    def initialize(base_url:, jwt_token:, timeout: 10)
      @base_url = base_url
      @jwt_token = jwt_token
      @timeout = timeout
    end

    # Performs a GET request to the specified path.
    #
    # @param path [String] The API endpoint path.
    # @return [Hash] The parsed JSON response from the API.
    def get(path)
      uri = URI("#{@base_url}#{path}")
      request = Net::HTTP::Get.new(uri)
      add_headers(request)

      execute_request(uri, request)
    end

    # Performs a POST request to the specified path with the given body.
    #
    # @param path [String] The API endpoint path.
    # @param body [Hash] The request body as a hash.
    # @return [Hash] The parsed JSON response from the API.
    def post(path, body)
      uri = URI("#{@base_url}#{path}")
      request = Net::HTTP::Post.new(uri)
      add_headers(request)
      request.body = body.to_json

      execute_request(uri, request)
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
    # @return [Hash] The parsed JSON response from the API.
    # @raise [Belpost::ApiError] If the API returns an error response.
    def execute_request(uri, request)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == "https"
      http.read_timeout = @timeout
      response = http.request(request)

      case response.code
      when "200"
        JSON.parse(response.body)
      else
        raise ApiError, "API error: #{response.body}"
      end
    end
  end
end
