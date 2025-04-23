# frozen_string_literal: true

RSpec.describe Belpost::Validation::PostcodeSchema do
  subject(:schema) { described_class.new }

  describe "postcode validation" do
    context "when postcode is valid" do
      it "validates a 6-digit postcode" do
        result = schema.call(postcode: "220001")
        expect(result).to be_success
      end
    end

    context "when postcode is invalid" do
      it "fails when postcode is empty" do
        result = schema.call(postcode: "")
        expect(result.errors[:postcode]).to include("must be filled")
      end

      it "fails when postcode is nil" do
        result = schema.call(postcode: nil)
        expect(result.errors[:postcode]).to include("must be filled")
      end

      it "fails when postcode is not a string" do
        result = schema.call(postcode: 123456)
        expect(result.errors[:postcode]).to include("must be a string")
      end

      it "fails when postcode is not 6 digits" do
        result = schema.call(postcode: "12345")
        expect(result.errors[:postcode]).to include("must be 6 digits")
      end

      it "fails when postcode contains non-digits" do
        result = schema.call(postcode: "12345A")
        expect(result.errors[:postcode]).to include("must be 6 digits")
      end
    end
  end
end 