# frozen_string_literal: true

require "belpost"
require "dotenv"

# Load environment variables from .env.test if it exists
Dotenv.load(".env.test")

# Ensure test environment has necessary variables
ENV["BELPOST_API_URL"] ||= "https://test-api.belpost.by"
ENV["BELPOST_JWT_TOKEN"] ||= "test-token-for-testing"
ENV["BELPOST_TIMEOUT"] ||= "5"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  
  # Reset configuration before each test
  config.before(:each) do
    Belpost.reset
  end
end
