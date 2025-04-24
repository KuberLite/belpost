# frozen_string_literal: true

require "spec_helper"

RSpec.describe Belpost::Models::BatchStatus do
  describe ".translate" do
    it "translates 'uncommitted' to 'в обработке'" do
      expect(described_class.translate("uncommitted")).to eq("в обработке")
    end

    it "translates 'committed' to 'Сформированна'" do
      expect(described_class.translate("committed")).to eq("Сформированна")
    end

    it "returns original value for unknown status" do
      expect(described_class.translate("unknown_status")).to eq("unknown_status")
    end
  end

  describe ".all" do
    it "returns an array of all possible statuses" do
      expect(described_class.all).to eq(%w[uncommitted committed])
    end
  end

  describe ".valid?" do
    it "returns true for valid statuses" do
      expect(described_class.valid?("uncommitted")).to be true
      expect(described_class.valid?("committed")).to be true
    end

    it "returns false for invalid statuses" do
      expect(described_class.valid?("invalid")).to be false
      expect(described_class.valid?(nil)).to be false
    end
  end
end 