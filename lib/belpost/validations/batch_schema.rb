# frozen_string_literal: true

require "dry-validation"

module Belpost
  module Validation
    # Schema for validating batch mailing data
    class BatchSchema < Dry::Validation::Contract
      params do
        required(:postal_delivery_type).filled(:str?).value(
          included_in?: %w[
            ordered_small_package
            letter_declare_value
            package
            ems
            ordered_parcel_post
            ordered_letter
            ordered_postcard
            small_package_declare_value
            package_declare_value
            ecommerce_economical
            ecommerce_standard
            ecommerce_elite
            ecommerce_express
            ecommerce_light
            ecommerce_optima
          ]
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
    end
  end
end 