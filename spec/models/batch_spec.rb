# frozen_string_literal: true

require "spec_helper"

RSpec.describe Belpost::Models::Batch do
  describe "#initialize" do
    let(:valid_data) do
      {
        postal_delivery_type: "ordered_small_package",
        direction: "internal",
        payment_type: "cash",
        negotiated_rate: true,
        name: "Test Batch",
        card_number: "1234567890",
        postal_items_in_ops: true,
        category: 1,
        is_document: false,
        is_declared_value: true,
        is_partial_receipt: false
      }
    end

    it "sets all attributes correctly" do
      batch = described_class.new(valid_data)

      expect(batch.postal_delivery_type).to eq("ordered_small_package")
      expect(batch.direction).to eq("internal")
      expect(batch.payment_type).to eq("cash")
      expect(batch.negotiated_rate).to eq(true)
      expect(batch.name).to eq("Test Batch")
      expect(batch.card_number).to eq("1234567890")
      expect(batch.postal_items_in_ops).to eq(true)
      expect(batch.category).to eq(1)
      expect(batch.is_document).to eq(false)
      expect(batch.is_declared_value).to eq(true)
      expect(batch.is_partial_receipt).to eq(false)
    end

    it "handles missing optional attributes" do
      data = valid_data.slice(:postal_delivery_type, :direction, :payment_type, :negotiated_rate)
      batch = described_class.new(data)

      expect(batch.name).to be_nil
      expect(batch.card_number).to be_nil
      expect(batch.postal_items_in_ops).to be_nil
      expect(batch.category).to be_nil
      expect(batch.is_document).to be_nil
      expect(batch.is_declared_value).to be_nil
      expect(batch.is_partial_receipt).to be_nil
    end
  end

  describe "#to_h" do
    let(:valid_data) do
      {
        postal_delivery_type: "ordered_small_package",
        direction: "internal",
        payment_type: "cash",
        negotiated_rate: true,
        name: "Test Batch",
        card_number: "1234567890",
        postal_items_in_ops: true,
        category: 1,
        is_document: false,
        is_declared_value: true,
        is_partial_receipt: false
      }
    end

    it "converts batch to hash with all attributes" do
      batch = described_class.new(valid_data)
      hash = batch.to_h

      expect(hash).to eq(valid_data)
    end

    it "includes only present attributes in hash" do
      data = valid_data.slice(:postal_delivery_type, :direction, :payment_type, :negotiated_rate)
      batch = described_class.new(data)
      hash = batch.to_h

      expect(hash).to eq(data)
    end
  end
end 