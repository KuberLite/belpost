# frozen_string_literal: true

module Belpost
  class Error < StandardError; end
  class AuthenticationError < Error; end
  class ApiError < Error; end
  class InvalidRequestError < Error; end
end
