# frozen_string_literal: true

require "spec_helper"

RSpec.describe Belpost::Validation::BatchSchema do
  subject(:schema) { described_class.new }

  describe "validation rules" do
    let(:valid_data) do
      {
        postal_delivery_type: "ordered_small_package",
        direction: "internal",
        payment_type: "cash",
        negotiated_rate: true
      }
    end

    context "with valid data" do
      it "is valid" do
        result = schema.call(valid_data)
        expect(result).to be_success
        expect(result.errors).to be_empty
      end

      it "accepts all valid postal delivery types" do
        valid_types = %w[
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

        valid_types.each do |type|
          data = valid_data.merge(postal_delivery_type: type)
          
          # Add required parameters for ecommerce types
          if type.start_with?("ecommerce_")
            data.merge!(
              negotiated_rate: false,
              is_declared_value: true,
              is_partial_receipt: false,
              postal_items_in_ops: true
            )
          end
          
          result = schema.call(data)
          expect(result).to be_success, "Expected #{type} to be valid"
        end
      end

      it "accepts all valid directions" do
        valid_directions = %w[internal CIS international]

        valid_directions.each do |direction|
          data = valid_data.merge(direction: direction)
          result = schema.call(data)
          expect(result).to be_success, "Expected #{direction} to be valid"
        end
      end

      it "accepts all valid payment types" do
        valid_payment_types = %w[
          not_specified
          cash
          payment_order
          electronic_personal_account
          4
          5
          commitment_letter
        ]

        valid_payment_types.each do |payment_type|
          data = valid_data.merge(payment_type: payment_type)
          result = schema.call(data)
          expect(result).to be_success, "Expected #{payment_type} to be valid"
        end
      end

      it "accepts optional fields" do
        data = valid_data.merge(
          name: "Test Batch",
          card_number: "1234567890",
          postal_items_in_ops: true,
          category: 1,
          is_document: false,
          is_declared_value: true,
          is_partial_receipt: false
        )

        result = schema.call(data)
        expect(result).to be_success
        expect(result.errors).to be_empty
      end
    end

    context "with invalid data" do
      it "requires postal_delivery_type" do
        data = valid_data.except(:postal_delivery_type)
        result = schema.call(data)
        expect(result).to be_failure
        expect(result.errors[:postal_delivery_type]).to include("is missing")
      end

      it "validates postal_delivery_type values" do
        data = valid_data.merge(postal_delivery_type: "invalid_type")
        result = schema.call(data)
        expect(result).to be_failure
        expect(result.errors[:postal_delivery_type]).to include("must be one of: ordered_small_package, letter_declare_value, package, ems, ordered_parcel_post, ordered_letter, ordered_postcard, small_package_declare_value, package_declare_value, ecommerce_economical, ecommerce_standard, ecommerce_elite, ecommerce_express, ecommerce_light, ecommerce_optima")
      end

      it "requires direction" do
        data = valid_data.except(:direction)
        result = schema.call(data)
        expect(result).to be_failure
        expect(result.errors[:direction]).to include("is missing")
      end

      it "validates direction values" do
        data = valid_data.merge(direction: "invalid_direction")
        result = schema.call(data)
        expect(result).to be_failure
        expect(result.errors[:direction]).to include("must be one of: internal, CIS, international")
      end

      it "requires payment_type" do
        data = valid_data.except(:payment_type)
        result = schema.call(data)
        expect(result).to be_failure
        expect(result.errors[:payment_type]).to include("is missing")
      end

      it "validates payment_type values" do
        data = valid_data.merge(payment_type: "invalid_payment")
        result = schema.call(data)
        expect(result).to be_failure
        expect(result.errors[:payment_type]).to include("must be one of: not_specified, cash, payment_order, electronic_personal_account, 4, 5, commitment_letter")
      end

      it "requires negotiated_rate" do
        data = valid_data.except(:negotiated_rate)
        result = schema.call(data)
        expect(result).to be_failure
        expect(result.errors[:negotiated_rate]).to include("is missing")
      end

      it "validates negotiated_rate is boolean" do
        data = valid_data.merge(negotiated_rate: "not_boolean")
        result = schema.call(data)
        expect(result).to be_failure
        expect(result.errors[:negotiated_rate]).to include("must be boolean")
      end
    end

    context "with ecommerce type specific validations" do
      context "with ecommerce_economical type" do
        let(:ecommerce_data) do
          valid_data.merge(
            postal_delivery_type: "ecommerce_economical",
            negotiated_rate: false,
            is_declared_value: true,
            is_partial_receipt: false,
            postal_items_in_ops: true
          )
        end

        it "validates correct parameters" do
          result = schema.call(ecommerce_data)
          expect(result).to be_success
          expect(result.errors).to be_empty
        end

        it "validates incorrect negotiated_rate" do
          data = ecommerce_data.merge(negotiated_rate: true)
          result = schema.call(data)
          expect(result).to be_failure
          expect(result.errors[:postal_delivery_type]).to include("negotiated_rate must be false for ecommerce_economical")
        end

        it "validates incorrect is_partial_receipt" do
          data = ecommerce_data.merge(is_partial_receipt: true)
          result = schema.call(data)
          expect(result).to be_failure
          expect(result.errors[:postal_delivery_type]).to include("is_partial_receipt must be false for ecommerce_economical")
        end

        it "validates incorrect postal_items_in_ops" do
          data = ecommerce_data.merge(postal_items_in_ops: false)
          result = schema.call(data)
          expect(result).to be_failure
          expect(result.errors[:postal_delivery_type]).to include("postal_items_in_ops must be one of [true] for ecommerce_economical")
        end
      end

      context "with ecommerce_standard type" do
        let(:ecommerce_data) do
          valid_data.merge(
            postal_delivery_type: "ecommerce_standard",
            negotiated_rate: false,
            is_declared_value: true,
            is_partial_receipt: false,
            postal_items_in_ops: true
          )
        end

        it "validates correct parameters" do
          result = schema.call(ecommerce_data)
          expect(result).to be_success
          expect(result.errors).to be_empty
        end

        it "validates incorrect negotiated_rate" do
          data = ecommerce_data.merge(negotiated_rate: true)
          result = schema.call(data)
          expect(result).to be_failure
          expect(result.errors[:postal_delivery_type]).to include("negotiated_rate must be false for ecommerce_standard")
        end
      end
    end
  end
end 