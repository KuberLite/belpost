# frozen_string_literal: true

RSpec.describe Belpost::Validation::AddressSchema do
  subject(:schema) { described_class.new }

  describe "address validation and formatting" do
    context "when address is valid" do
      it "formats address with корпус" do
        result = schema.call(address: "город Минск улица Автодоровская 3Е корпус 4")
        expect(result.errors[:address].first).to eq("город Минск улица Автодоровская 3Е/4")
      end

      it "formats address with корп" do
        result = schema.call(address: "ул. Ленина 5 корп 2")
        expect(result.errors[:address].first).to eq("ул. Ленина 5/2")
      end

      it "formats address with кор" do
        result = schema.call(address: "пр. Независимости 10 кор 3")
        expect(result.errors[:address].first).to eq("пр. Независимости 10/3")
      end

      it "formats address with к" do
        result = schema.call(address: "ул. Сурганова 2 к 1")
        expect(result.errors[:address].first).to eq("ул. Сурганова 2/1")
      end

      it "converts lowercase letter to uppercase" do
        result = schema.call(address: "ул. Ленина 5а/2")
        expect(result.errors[:address].first).to eq("ул. Ленина 5А/2")
      end

      it "removes extra spaces" do
        result = schema.call(address: "ул.  Ленина  5  корпус  2")
        expect(result.errors[:address].first).to eq("ул. Ленина 5/2")
      end

      it "formats address with multiple building indicators" do
        result = schema.call(address: "ул. Ленина 5 корпус 2 корпус 3")
        expect(result.errors[:address].first).to eq("ул. Ленина 5/2/3")
      end
    end

    context "when address is invalid" do
      it "fails when address is empty" do
        result = schema.call(address: "")
        expect(result.errors[:address]).to include("must be filled")
      end

      it "fails when address is nil" do
        result = schema.call(address: nil)
        expect(result.errors[:address]).to include("must be filled")
      end

      it "fails when address is not a string" do
        result = schema.call(address: 123)
        expect(result.errors[:address]).to include("must be a string")
      end
    end
  end
end 