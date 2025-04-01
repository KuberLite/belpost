# frozen_string_literal: true

RSpec.describe Belpost::Client do
  let(:jwt_token) { "test-jwt-token" }
  let(:base_url) { "https://api.belpost.by" }
  let(:api_service) { instance_double(Belpost::ApiService) }
  let(:logger) { instance_double(Logger, info: nil, debug: nil) }

  before do
    Belpost.configure do |config|
      config.jwt_token = jwt_token
      config.base_url = base_url
      config.timeout = 10
    end

    allow(Belpost::ApiService).to receive(:new).and_return(api_service)
  end

  after do
    Belpost.reset
  end

  describe "#initialize" do
    it "creates a client instance with configuration" do
      client = described_class.new(logger: logger)
      expect(Belpost::ApiService).to have_received(:new).with(
        base_url: base_url,
        jwt_token: jwt_token,
        timeout: 10,
        logger: logger
      )
    end

    it "raises ConfigurationError when jwt_token is not set" do
      Belpost.configure { |config| config.jwt_token = nil }
      expect { described_class.new(logger: logger) }.to raise_error(Belpost::ConfigurationError, /JWT token is required/)
    end
  end

  describe "#create_parcel" do
    let(:client) { described_class.new(logger: logger) }
    let(:parcel_data) do
      {
        parcel: {
          type: "package",
          attachment_type: "products",
          measures: {
            weight: 1000
          },
          departure: {
            country: "BY",
            place: "post_office"
          },
          arrival: {
            country: "BY",
            place: "post_office"
          }
        },
        sender: {
          type: "legal_person",
          info: {
            organization_name: "ООО \"Компания\""
          },
          location: {
            code: "220000",
            region: "Минская",
            district: "Минский",
            locality: {
              type: "город",
              name: "Минск"
            },
            road: {
              type: "проспект",
              name: "Независимости"
            },
            building: "123"
          },
          email: "test@example.com",
          phone: "375291234567"
        },
        recipient: {
          type: "natural_person",
          info: {
            first_name: "Иван",
            last_name: "Иванов"
          },
          location: {
            code: "220000",
            region: "Минская",
            district: "Минский",
            locality: {
              type: "город",
              name: "Минск"
            },
            road: {
              type: "проспект",
              name: "Независимости"
            },
            building: "456"
          },
          phone: "375291234567"
        }
      }
    end
    let(:response_data) do
      {
        "id" => 123,
        "data" => {
          "parcel" => {
            "s10code" => "BV000123456BY"
          }
        }
      }
    end
    let(:validation_result) { double("validation_result", success?: true) }
    let(:api_response) { instance_double(Belpost::Models::ApiResponse, to_h: response_data) }

    before do
      allow(Belpost::Validation::ParcelSchema).to receive(:call).and_return(validation_result)
      allow(api_service).to receive(:post).and_return(api_response)
    end

    it "validates the parcel data" do
      client.create_parcel(parcel_data)
      expect(Belpost::Validation::ParcelSchema).to have_received(:call).with(parcel_data)
    end

    it "raises ValidationError when validation fails" do
      allow(validation_result).to receive(:success?).and_return(false)
      allow(validation_result).to receive(:errors).and_return(double(to_h: { error: "message" }))

      expect { client.create_parcel(parcel_data) }.to raise_error(Belpost::ValidationError)
    end

    it "creates a parcel using the API service" do
      client.create_parcel(parcel_data)
      expect(api_service).to have_received(:post).with(
        "/api/v1/business/postal-deliveries",
        parcel_data
      )
    end

    it "returns the API response data" do
      result = client.create_parcel(parcel_data)
      expect(result).to eq(response_data)
    end
  end

  describe "#fetch_hs_codes" do
    let(:client) { described_class.new(logger: logger) }
    let(:response_data) { [{ "code" => "1234", "name" => "Test" }] }
    let(:api_response) { instance_double(Belpost::Models::ApiResponse, to_h: response_data) }

    before do
      allow(api_service).to receive(:get).and_return(api_response)
    end

    it "fetches HS codes using the API service" do
      client.fetch_hs_codes
      expect(api_service).to have_received(:get).with("/api/v1/business/postal-deliveries/hs-codes/list")
    end

    it "returns the API response data" do
      result = client.fetch_hs_codes
      expect(result).to eq(response_data)
    end
  end

  describe "#validate_postal_delivery" do
    let(:client) { described_class.new(logger: logger) }
    let(:country_code) { "BY" }
    let(:response_data) { { "valid" => true } }
    let(:api_response) { instance_double(Belpost::Models::ApiResponse, to_h: response_data) }

    before do
      allow(api_service).to receive(:get).and_return(api_response)
    end

    it "fetches validation data using the API service" do
      client.validate_postal_delivery(country_code)
      expect(api_service).to have_received(:get).with("/api/v1/business/postal-deliveries/validation/BY")
    end

    it "converts country code to uppercase" do
      client.validate_postal_delivery("by")
      expect(api_service).to have_received(:get).with("/api/v1/business/postal-deliveries/validation/BY")
    end

    it "returns the API response data" do
      result = client.validate_postal_delivery(country_code)
      expect(result).to eq(response_data)
    end
  end

  describe "#fetch_available_countries" do
    let(:client) { described_class.new(logger: logger) }
    let(:response_data) { [{ "code" => "BY", "name" => "Belarus" }] }
    let(:api_response) { instance_double(Belpost::Models::ApiResponse, to_h: response_data) }

    before do
      allow(api_service).to receive(:get).and_return(api_response)
    end

    it "fetches available countries using the API service" do
      client.fetch_available_countries
      expect(api_service).to have_received(:get).with("/api/v1/business/postal-deliveries/countries")
    end

    it "returns the API response data" do
      result = client.fetch_available_countries
      expect(result).to eq(response_data)
    end
  end

  describe "#find_address_by_string" do
    let(:client) { described_class.new }
    let(:address) { "город Минск улица Автодоровская 3Е корпус 4" }
    let(:formatted_address) { "город Минск улица Автодоровская 3Е/4" }
    let(:api_response) { { "data" => [{ "address" => "test" }] } }

    before do
      allow(api_service).to receive(:get).with(
        "/api/v1/business/geo-directory/search-address",
        { search: formatted_address }
      ).and_return(Belpost::Models::ApiResponse.new(
        data: api_response,
        status_code: 200,
        headers: {}
      ))
    end

    it "formats address and sends request to API" do
      result = client.find_address_by_string(address)
      expect(result).to eq(api_response)
      expect(api_service).to have_received(:get).with(
        "/api/v1/business/geo-directory/search-address",
        { search: formatted_address }
      )
    end

    context "when address is invalid" do
      it "raises ValidationError for empty address" do
        expect { client.find_address_by_string("") }.to raise_error(
          Belpost::ValidationError,
          /must be filled/
        )
      end

      it "raises ValidationError for nil address" do
        expect { client.find_address_by_string(nil) }.to raise_error(
          Belpost::ValidationError,
          /must be filled/
        )
      end

      it "raises ValidationError for non-string address" do
        expect { client.find_address_by_string(123) }.to raise_error(
          Belpost::ValidationError,
          /must be a string/
        )
      end
    end

    context "when API returns error" do
      before do
        allow(api_service).to receive(:get).and_raise(
          Belpost::ApiError.new("API Error")
        )
      end

      it "raises ApiError" do
        expect { client.find_address_by_string(address) }.to raise_error(
          Belpost::ApiError,
          "API Error"
        )
      end
    end
  end
end 