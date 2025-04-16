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
end 