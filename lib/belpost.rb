# frozen_string_literal: true

require_relative "belpost/version"
require_relative "belpost/configuration"
require_relative "belpost/errors"
require_relative "belpost/retry"
require_relative "belpost/api_paths"
require_relative "belpost/api_service"

# Load models
require_relative "belpost/models/api_response"
require_relative "belpost/models/batch"
require_relative "belpost/models/customs_declaration"
require_relative "belpost/models/parcel"
require_relative "belpost/models/parcel_builder"

# Load types and validations
require_relative "belpost/postal_delivery_types"
require_relative "belpost/validations/batch_schema"
require_relative "belpost/validations/parcel_schema"

# Load client last as it depends on other files
require_relative "belpost/client"

# Module for working with Belpochta API.
# Provides an interface for configuring and interacting with the API.
module Belpost
  class Error < StandardError; end

  # Setting up the API configuration.
  # @yieldparam config [Belpost::Configuration] configuration object.
  def self.configure
    yield configuration
  end

  # Returns the current configuration.
  # @return [Belpost::Configuration]
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Resets the configuration to default values.
  def self.reset
    @configuration = Configuration.new
  end
end
