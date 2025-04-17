# frozen_string_literal: true

require "spec_helper"

RSpec.describe Belpost::PostalDeliveryTypes do
  describe ".valid?" do
    it "returns true for valid types" do
      expect(described_class.valid?("ordered_small_package")).to be true
      expect(described_class.valid?("ecommerce_optima")).to be true
    end

    it "returns false for invalid types" do
      expect(described_class.valid?("invalid_type")).to be false
      expect(described_class.valid?(nil)).to be false
    end
  end

  describe ".all" do
    it "returns all valid types" do
      types = described_class.all
      expect(types).to include(:ordered_small_package)
      expect(types).to include(:ecommerce_optima)
      expect(types).not_to include(:invalid_type)
    end
  end

  describe ".description" do
    it "returns the description for a valid type" do
      expect(described_class.description("ordered_small_package")).to eq("Заказной мелкий пакет республиканский")
      expect(described_class.description("ecommerce_optima")).to eq("Отправление E-commerce Оптима")
    end

    it "returns nil for an invalid type" do
      expect(described_class.description("invalid_type")).to be_nil
    end
  end

  describe ".validation_rules" do
    it "returns rules for ecommerce types" do
      rules = described_class.validation_rules("ecommerce_economical")
      expect(rules).to include(
        negotiated_rate: false,
        declared_value: [true, false],
        partial_receipt: false,
        postal_items_in_ops: true
      )
    end

    it "returns nil for non-ecommerce types" do
      expect(described_class.validation_rules("ordered_small_package")).to be_nil
    end

    it "returns nil for invalid types" do
      expect(described_class.validation_rules("invalid_type")).to be_nil
    end
  end

  describe ".validate_params" do
    context "with ecommerce_economical type" do
      let(:type) { "ecommerce_economical" }

      it "validates correct parameters" do
        params = {
          negotiated_rate: false,
          is_declared_value: true,
          is_partial_receipt: false,
          postal_items_in_ops: true
        }
        expect(described_class.validate_params(type, params)).to be_empty
      end

      it "validates incorrect negotiated_rate" do
        params = {
          negotiated_rate: true,
          is_declared_value: true,
          is_partial_receipt: false,
          postal_items_in_ops: true
        }
        errors = described_class.validate_params(type, params)
        expect(errors).to include("negotiated_rate must be false for ecommerce_economical")
      end

      it "validates incorrect is_partial_receipt" do
        params = {
          negotiated_rate: false,
          is_declared_value: true,
          is_partial_receipt: true,
          postal_items_in_ops: true
        }
        errors = described_class.validate_params(type, params)
        expect(errors).to include("is_partial_receipt must be false for ecommerce_economical")
      end

      it "validates incorrect postal_items_in_ops" do
        params = {
          negotiated_rate: false,
          is_declared_value: true,
          is_partial_receipt: false,
          postal_items_in_ops: false
        }
        errors = described_class.validate_params(type, params)
        expect(errors).to include("postal_items_in_ops must be one of [true] for ecommerce_economical")
      end
    end

    context "with ecommerce_standard type" do
      let(:type) { "ecommerce_standard" }

      it "validates correct parameters" do
        params = {
          negotiated_rate: false,
          is_declared_value: true,
          is_partial_receipt: false,
          postal_items_in_ops: true
        }
        expect(described_class.validate_params(type, params)).to be_empty
      end

      it "validates incorrect negotiated_rate" do
        params = {
          negotiated_rate: true,
          is_declared_value: true,
          is_partial_receipt: false,
          postal_items_in_ops: true
        }
        errors = described_class.validate_params(type, params)
        expect(errors).to include("negotiated_rate must be false for ecommerce_standard")
      end
    end

    it "returns empty array for non-ecommerce types" do
      params = {
        negotiated_rate: true,
        is_declared_value: true,
        is_partial_receipt: true,
        postal_items_in_ops: true
      }
      expect(described_class.validate_params("ordered_small_package", params)).to be_empty
    end

    it "returns empty array for invalid types" do
      params = {
        negotiated_rate: true,
        is_declared_value: true,
        is_partial_receipt: true,
        postal_items_in_ops: true
      }
      expect(described_class.validate_params("invalid_type", params)).to be_empty
    end
  end
end 