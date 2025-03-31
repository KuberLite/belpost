# frozen_string_literal: true

RSpec.describe Belpost::Models::Parcel do
  let(:parcel_data) do
    {
      "weight" => 1500,
      "dimensions" => { "length" => 300, "width" => 200, "height" => 100 },
      "type" => "package",
      "description" => "Тестовая посылка"
    }
  end

  subject(:parcel) { described_class.new(parcel_data) }

  describe "#initialize" do
    it "creates a new parcel with provided data" do
      expect(parcel.data).to eq(parcel_data)
    end
  end

  describe "#to_h" do
    it "returns the parcel data as a hash" do
      expect(parcel.to_h).to eq(parcel_data)
    end
  end

  describe "#to_json" do
    it "returns the parcel data as a JSON string" do
      expect(parcel.to_json).to eq(parcel_data.to_json)
    end
  end
end 