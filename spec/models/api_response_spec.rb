# frozen_string_literal: true

RSpec.describe Belpost::Models::ApiResponse do
  let(:response_data) do 
    {
      "id" => 12345,
      "data" => {
        "parcel" => {
          "s10code" => "BV000123456BY"
        }
      },
      "labels" => ["address_label"]
    }
  end
  let(:status_code) { 200 }
  let(:headers) { { "content-type" => ["application/json"] } }

  subject(:response) { described_class.new(data: response_data, status_code: status_code, headers: headers) }

  describe "#initialize" do
    it "creates a new response with the provided data" do
      expect(response.data).to eq(response_data)
      expect(response.status_code).to eq(status_code)
      expect(response.headers).to eq(headers)
    end
  end

  describe "#success?" do
    context "when status code is 200" do
      it "returns true" do
        expect(response.success?).to be true
      end
    end

    context "when status code is not 200" do
      let(:status_code) { 400 }

      it "returns false" do
        expect(response.success?).to be false
      end
    end
  end

  describe "#to_h" do
    it "returns the response data as a hash" do
      expect(response.to_h).to eq(response_data)
    end
  end
end 