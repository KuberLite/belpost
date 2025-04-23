# frozen_string_literal: true

require "spec_helper"

RSpec.describe "find_addresses_by_postcode method" do
  let(:jwt_token) { "test-token" }
  let(:base_url) { "https://api.belpost.by" }
  let(:api_service) { instance_double(Belpost::ApiService) }
  let(:logger) { instance_double(Logger, info: nil, debug: nil) }
  let(:client) { Belpost::Client.new(logger: logger) }
  
  before do
    Belpost.configure do |config|
      config.jwt_token = jwt_token
      config.base_url = base_url
      config.timeout = 10
    end
    
    allow(Belpost::ApiService).to receive(:new).and_return(api_service)
  end
  
  describe "#find_addresses_by_postcode" do
    context "validation" do
      let(:postcode_schema) { instance_double(Belpost::Validation::PostcodeSchema) }
      let(:validation_result) { instance_double(Dry::Validation::Result) }
      
      before do
        allow(Belpost::Validation::PostcodeSchema).to receive(:new).and_return(postcode_schema)
        allow(postcode_schema).to receive(:call).and_return(validation_result)
        allow(validation_result).to receive(:success?).and_return(false)
        allow(validation_result).to receive(:errors).and_return(double(to_h: { error: "message" }))
      end
      
      it "validates that postcode is 6 digits" do
        expect { client.find_addresses_by_postcode("12345") }.to raise_error(Belpost::ValidationError)
        expect { client.find_addresses_by_postcode("1234567") }.to raise_error(Belpost::ValidationError)
        expect { client.find_addresses_by_postcode("abcdef") }.to raise_error(Belpost::ValidationError)
        expect { client.find_addresses_by_postcode("") }.to raise_error(Belpost::ValidationError)
        expect { client.find_addresses_by_postcode(nil) }.to raise_error(Belpost::ValidationError)
      end
    end
    
    context "API call" do
      let(:postcode) { "220001" }
      let(:addresses) do
        [
          {
            "postcode" => "220001",
            "region" => "Минская",
            "district" => "Минский",
            "city" => "Минск",
            "city_type" => "город",
            "buildings" => "1, 2, 3",
            "street" => "Ленина",
            "street_type" => "улица",
            "short_address" => "220001, город Минск, улица Ленина",
            "autocomplete_address" => "220001, город Минск, улица Ленина"
          }
        ]
      end
      let(:validation_result) { instance_double(Dry::Validation::Result, success?: true) }
      let(:api_response) { instance_double(Belpost::Models::ApiResponse, to_h: addresses) }
      
      before do
        allow(Belpost::Validation::PostcodeSchema).to receive(:new).and_return(
          instance_double(Belpost::Validation::PostcodeSchema, call: validation_result)
        )
        allow(api_service).to receive(:get).and_return(api_response)
      end
      
      it "calls the API with the correct parameters" do
        result = client.find_addresses_by_postcode(postcode)
        
        expect(api_service).to have_received(:get).with(
          Belpost::ApiPaths::GEO_DIRECTORY_ADDRESSES,
          { postcode: postcode }
        )
        expect(result).to eq(addresses)
      end
    end
  end
end 