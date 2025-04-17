# frozen_string_literal: true

require "dry-validation"

module Belpost
  module Validation
    # Schema for validating batch mailing data
    class BatchSchema < Dry::Validation::Contract
      params do
        required(:postal_delivery_type).filled(:str?).value(
          included_in?: Belpost::PostalDeliveryTypes.all.map(&:to_s)
        )

        required(:direction).filled(:str?).value(
          included_in?: %w[internal CIS international]
        )

        required(:payment_type).filled(:str?).value(
          included_in?: %w[
            not_specified
            cash
            payment_order
            electronic_personal_account
            4
            5
            commitment_letter
          ]
        )

        required(:negotiated_rate).filled(:bool?)

        optional(:name).maybe(:str?)
        optional(:card_number).maybe(:str?)
        optional(:postal_items_in_ops).maybe(:bool?)
        optional(:category).maybe(:int?)
        optional(:is_document).maybe(:bool?)
        optional(:is_declared_value).maybe(:bool?)
        optional(:is_partial_receipt).maybe(:bool?)
      end

      rule(:postal_delivery_type) do
        if key? && value
          errors = Belpost::PostalDeliveryTypes.validate_params(
            value,
            values
          )
          errors.each { |error| key.failure(error) }
        end
      end
    end
  end
end 