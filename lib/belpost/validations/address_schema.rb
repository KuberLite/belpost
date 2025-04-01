# frozen_string_literal: true

require "dry-validation"

module Belpost
  module Validation
    # Schema for validating and formatting address strings
    class AddressSchema < Dry::Validation::Contract
      params do
        required(:address).filled(:string)
      end

      rule(:address) do
        # Remove extra spaces
        address = value.gsub(/\s+/, " ").strip
        
        # Replace building indicators with "/"
        address = address.gsub(/\s+(корпус|корп|кор|к)\s+/, "/")
        
        # Ensure building number format (no spaces between number, letter, and building)
        address = address.gsub(/(\d+)\s*([А-Я])\s*(\d+)/, '\1\2/\3')
        
        # Ensure letter is uppercase
        address = address.gsub(/(\d+)([а-я])(\/\d+)/) { |m| "#{$1}#{$2.upcase}#{$3}" }
        
        key.failure(address)
      end
    end
  end
end 