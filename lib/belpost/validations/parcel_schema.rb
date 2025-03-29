# frozen_string_literal: true

require "dry-validation"

module Belpost
  # rubocop:disable Metrics/ModuleLength
  module Validation
    # Validation schema for parcel_data
    # rubocop:disable Metrics/BlockLength
    ParcelSchema = Dry::Validation.JSON do
      # 1. Parcel information
      required(:parcel).schema do
        optional(:s10code).maybe(:string) # Tracking code (optional)
        required(:type).filled(included_in?: %w[package small_package small_valued_package ems]) # Parcel type
        required(:attachment_type).filled(included_in?: %w[products documents]) # Attachment type
        required(:measures).hash do
          optional(:long).maybe(:integer) # Length (optional)
          optional(:width).maybe(:integer) # Width (optional)
          optional(:height).maybe(:integer) # Height (optional)
          required(:weight).filled(:integer) # Weight (required)
        end
        required(:departure).hash do
          required(:country).filled(eql?: "BY") # Sending country (always BY)
          required(:place).filled(included_in?: %w[post_office]) # Sending location
          optional(:place_uuid).maybe(:string) # Unique identifier of the location (optional)
        end
        required(:arrival).hash do
          required(:country).filled(:string) # Recipient country
          required(:place).filled(included_in?: %w[post_office]) # Recipient location
          optional(:place_uuid).maybe(:string) # Unique identifier of the location (optional)
        end
      end

      # 2. Additional services
      required(:addons).hash do
        optional(:declared_value).hash do
          required(:currency).filled(eql?: "BYN") # Declared value currency
          required(:value).filled(:float) # Declared value amount
        end
        optional(:cash_on_delivery).hash do
          required(:currency).filled(eql?: "BYN") # Cash on delivery currency
          required(:value).filled(:float) # Cash on delivery amount
        end
        optional(:IOSS).maybe(:string) # IOSS identification number
        optional(:registered_notification).maybe(:string) # Notification tracking code
        optional(:simple_notification).maybe(:bool) # Simple notification
        optional(:sms_notification).maybe(:bool) # SMS notification
        optional(:email_notification).maybe(:bool) # Email notification
        optional(:priority_parcel).maybe(:bool) # Priority parcel
        optional(:attachment_inventory).maybe(:bool) # Inventory list
        optional(:paid_shipping).maybe(:bool) # Paid shipping
        optional(:careful_fragile).maybe(:bool) # Fragile
        optional(:bulky).maybe(:bool) # Bulky
        optional(:ponderous).maybe(:bool) # Heavyweight
        optional(:payment_upon_receipt).maybe(:bool) # Payment upon receipt
        optional(:hand_over_personally).maybe(:bool) # Deliver personally
        optional(:return_of_documents).maybe(:bool) # Return documents
        optional(:open_upon_delivery).maybe(:bool) # Open upon delivery
        optional(:delivery_to_work).maybe(:bool) # Delivery to workplace
        optional(:time_of_delivery).maybe(:hash) do
          required(:type).filled(included_in?: %w[level1 level2 level3 level4]) # Delivery time type
          optional(:time_interval).hash do
            required(:from).filled(:string) # Start of time interval
            required(:to).filled(:string) # End of time interval
          end
        end
      end

      # 3. Sender information
      required(:sender).hash do
        required(:type).filled(included_in?: %w[natural_person legal_person sole_proprietor]) # Sender type
        required(:info).hash do
          optional(:organization_name).maybe(:string) # Organization name
          optional(:taxpayer_number).maybe(:string) # Taxpayer number
          optional(:bank).maybe(:string) # Bank name
          optional(:IBAN).maybe(:string) # IBAN
          optional(:BIC).maybe(:string) # BIC
        end
        required(:location).hash do
          required(:code).filled(:string) # Postal code
          required(:region).filled(:string) # Region
          required(:district).filled(:string) # District
          required(:locality).hash do
            required(:type).filled(:string) # Locality type
            required(:name).filled(:string) # Locality name
          end
          required(:road).hash do
            required(:type).filled(:string) # Street type
            required(:name).filled(:string) # Street name
          end
          required(:building).filled(:string) # Building number
          optional(:housing).maybe(:string) # Housing
          optional(:apartment).maybe(:string) # Apartment/Office
        end
        required(:email).filled(:string) # Sender email
        required(:phone).filled(:string) # Sender phone
      end

      # 4. Recipient information
      required(:recipient).hash do
        required(:type).filled(included_in?: %w[natural_person legal_person sole_proprietor]) # Recipient type
        required(:info).hash do
          optional(:first_name).maybe(:string) # First name
          optional(:second_name).maybe(:string) # Middle name
          optional(:last_name).maybe(:string) # Last name
          optional(:organization_name).maybe(:string) # Organization name
        end
        required(:location).hash do
          required(:code).filled(:string) # Postal code
          required(:region).filled(:string) # Region
          required(:district).filled(:string) # District
          required(:locality).hash do
            required(:type).filled(:string) # Locality type
            required(:name).filled(:string) # Locality name
          end
          required(:road).hash do
            required(:type).filled(:string) # Street type
            required(:name).filled(:string) # Street name
          end
          required(:building).filled(:string) # Building number
          optional(:housing).maybe(:string) # Housing
          optional(:apartment).maybe(:string) # Apartment/Office
        end
        required(:email).filled(:string) # Recipient email
        required(:phone).filled(:string) # Recipient phone
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
  # rubocop:enable Metrics/ModuleLength
end
