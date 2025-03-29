require "spec_helper"
require "belpost"

RSpec.describe BelpostApi::Client do
  let(:client) { BelpostApi::Client.new }

  before do
    BelpostApi.configure do |config|
      config.jwt_token = "test_token"
    end
  end

  it "creates a parcel successfully" do
    stub_request(:post, "https://api.belpost.by/api/v1/business/postal-deliveries")
      .with(headers: { "Authorization" => "Bearer test_token", "Accept" => "application/json" })
      .to_return(status: 200, body: { id: 62 }.to_json)

    parcel_data = {
      parcel: {
        s10code: "",
        type: "package",
        attachment_type: "products",
        measures: { weight: 12 },
        departure: { country: "BY", place_uuid: "", place: "post_office" },
        arrival: { country: "BY", place_uuid: "", place: "post_office" }
      }
    }

    response = client.create_parcel(parcel_data)
    expect(response["id"]).to eq(62)
  end
end