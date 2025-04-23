# frozen_string_literal: true

require "dry-validation"

module Belpost
  module Validation
    # Schema for validating postcode parameters
    class PostcodeSchema < Dry::Validation::Contract
      params do
        required(:postcode).filled(:string)
      end

      rule(:postcode) do
        key.failure("must be 6 digits") unless value.match?(/^\d{6}$/)
      end
    end
  end
end 