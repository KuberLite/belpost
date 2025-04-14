# frozen_string_literal: true

require "dry-validation"

module Belpost
  # rubocop:disable Metrics/ModuleLength
  module Validation
    # Validation schema for parcel_data
    # rubocop:disable Metrics/BlockLength
    class ParcelSchema < Dry::Validation::Contract
      params do
        required(:parcel).hash do
          required(:type).filled(:string, included_in?: %w[package small_package small_valued_package ems])
          required(:attachment_type).filled(:string, included_in?: %w[products documents])
          required(:measures).hash do
            required(:weight).filled(:integer, gt?: 0)
            optional(:long).value(:integer, gt?: 0)
            optional(:width).value(:integer, gt?: 0)
            optional(:height).value(:integer, gt?: 0)
          end
          required(:departure).hash do
            required(:country).filled(:string, eql?: "BY")
            required(:place).filled(:string, included_in?: %w[post_office])
            optional(:place_uuid).maybe(:string)
          end
          required(:arrival).hash do
            required(:country).filled(:string)
            required(:place).filled(:string, included_in?: %w[post_office])
            optional(:place_uuid).maybe(:string)
          end
          optional(:s10code).maybe(:string)
        end

        optional(:addons).hash do
          optional(:cash_on_delivery).maybe(:hash) do
            required(:currency).filled(:string, eql?: "BYN")
            required(:value).filled(:float, gt?: 0)
          end
          optional(:declared_value).maybe(:hash) do
            required(:currency).filled(:string, eql?: "BYN")
            required(:value).filled(:float, gt?: 0)
          end
          optional(:IOSS).maybe(:string)
          optional(:registered_notification).maybe(:string)
          optional(:simple_notification).maybe(:bool)
          optional(:sms_notification).maybe(:bool)
          optional(:email_notification).maybe(:bool)
          optional(:priority_parcel).maybe(:bool)
          optional(:attachment_inventory).maybe(:bool)
          optional(:paid_shipping).maybe(:bool)
          optional(:careful_fragile).maybe(:bool)
          optional(:bulky).maybe(:bool)
          optional(:ponderous).maybe(:bool)
          optional(:payment_upon_receipt).maybe(:bool)
          optional(:hand_over_personally).maybe(:bool)
          optional(:return_of_documents).maybe(:bool)
          optional(:open_upon_delivery).maybe(:bool)
          optional(:delivery_to_work).maybe(:bool)
          optional(:time_of_delivery).maybe(:hash) do
            required(:type).filled(:string, included_in?: %w[level1 level2 level3 level4])
            optional(:time_interval).hash do
              required(:from).filled(:string)
              required(:to).filled(:string)
            end
          end
        end

        optional(:sender).hash do
          required(:type).filled(:string, included_in?: %w[legal_person natural_person])
          required(:info).hash do
            optional(:organization_name).maybe(:string)
            optional(:taxpayer_number).maybe(:string)
            optional(:IBAN).maybe(:string)
            optional(:BIC).maybe(:string)
            optional(:bank).maybe(:string)
            optional(:first_name).maybe(:string)
            optional(:second_name).maybe(:string)
            optional(:last_name).maybe(:string)
          end
          required(:location).hash do
            required(:code).filled(:string)
            required(:region).filled(:string)
            required(:district).filled(:string)
            required(:locality).hash do
              required(:type).filled(:string)
              required(:name).filled(:string)
            end
            required(:road).hash do
              required(:type).filled(:string)
              required(:name).filled(:string)
            end
            required(:building).filled(:string)
            optional(:housing).maybe(:string)
            optional(:apartment).maybe(:string)
          end
          optional(:email).maybe(:string)
          optional(:phone).maybe(:string)
        end

        optional(:recipient).hash do
          required(:type).filled(:string, included_in?: %w[legal_person natural_person])
          required(:info).hash do
            optional(:organization_name).maybe(:string)
            optional(:taxpayer_number).maybe(:string)
            optional(:IBAN).maybe(:string)
            optional(:BIC).maybe(:string)
            optional(:bank).maybe(:string)
            optional(:first_name).maybe(:string)
            optional(:second_name).maybe(:string)
            optional(:last_name).maybe(:string)
          end
          required(:location).hash do
            required(:code).filled(:string)
            required(:region).filled(:string)
            required(:district).filled(:string)
            required(:locality).hash do
              required(:type).filled(:string)
              required(:name).filled(:string)
            end
            required(:road).hash do
              required(:type).filled(:string)
              required(:name).filled(:string)
            end
            required(:building).filled(:string)
            optional(:housing).maybe(:string)
            optional(:apartment).maybe(:string)
          end
          optional(:email).maybe(:string)
          optional(:phone).maybe(:string)
        end

        optional(:cp72).hash do
          optional(:items).array(:hash) do
            required(:name).filled(:string)
            required(:local).filled(:string)
            required(:unit).hash do
              required(:local).filled(:string)
              required(:en).filled(:string)
            end
            required(:count).filled(:integer, gt?: 0)
            required(:weight).filled(:integer, gt?: 0)
            required(:price).hash do
              required(:currency).filled(:string)
              required(:value).filled(:float, gt?: 0)
            end
            optional(:code).maybe(:string)
            optional(:country).maybe(:string)
          end
          optional(:price).hash do
            required(:currency).filled(:string)
            required(:value).filled(:float, gt?: 0)
          end
          optional(:category).filled(:string, included_in?: %w[gift documents sample returned_goods merchandise other])
          optional(:explanation).maybe(:string)
          optional(:comments).maybe(:string)
          optional(:invoice).maybe(:string)
          optional(:licences).array(:string)
          optional(:certificates).array(:string)
        end
      end

      # Add class method to make it compatible with the tests
      def self.call(params)
        new.call(params)
      end

      # Add validation rule for organization_name when sender type is legal_person
      rule('sender.info.organization_name') do
        key.failure('must be filled') if values[:sender] && values[:sender][:type] == 'legal_person' && !values.dig(:sender, :info, :organization_name)
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
  # rubocop:enable Metrics/ModuleLength
end
