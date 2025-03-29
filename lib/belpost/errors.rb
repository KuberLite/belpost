module BelpostApi
  class Error < StandardError; end
  class AuthenticationError < Error; end
  class ApiError < Error; end
  class InvalidRequestError < Error; end
end