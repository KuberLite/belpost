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

  describe "#search_postcode" do
    let(:client) { described_class.new }
    let(:city) { "Витебск" }
    let(:street) { "Ильинского" }
    let(:building) { "51/1" }
    let(:limit) { 50 }
    let(:api_response) do
      [{
        "postcode" => "210001",
        "region" => "Витебская",
        "district" => "Витебский",
        "city" => "Витебск",
        "city_type" => "город",
        "buildings" => "1, 1А, 3, 7, 13, 13А, 13к1",
        "street" => "Ильинского",
        "street_type" => "улица",
        "short_address" => "210001, город Витебск, улица Ильинского",
        "autocomplete_address" => "210001, город Витебск, улица Ильинского"
      }]
    end

    before do
      allow(api_service).to receive(:get).with(
        "/api/v1/business/geo-directory/postcode",
        { city: city, street: street, building: building, limit: limit }
      ).and_return(Belpost::Models::ApiResponse.new(
        data: api_response,
        status_code: 200,
        headers: {}
      ))
    end

    it "sends request to API with all parameters" do
      result = client.search_postcode(city: city, street: street, building: building, limit: limit)
      expect(result).to eq(api_response)
      expect(api_service).to have_received(:get).with(
        "/api/v1/business/geo-directory/postcode",
        { city: city, street: street, building: building, limit: limit }
      )
    end

    it "sends request without optional parameters" do
      allow(api_service).to receive(:get).with(
        "/api/v1/business/geo-directory/postcode",
        { city: city, street: street, limit: 50 }
      ).and_return(Belpost::Models::ApiResponse.new(
        data: api_response,
        status_code: 200,
        headers: {}
      ))

      result = client.search_postcode(city: city, street: street)
      expect(result).to eq(api_response)
      expect(api_service).to have_received(:get).with(
        "/api/v1/business/geo-directory/postcode",
        { city: city, street: street, limit: 50 }
      )
    end

    context "when no addresses are found" do
      before do
        allow(api_service).to receive(:get).with(
          "/api/v1/business/geo-directory/postcode",
          { city: city, street: street, limit: 50 }
        ).and_return(Belpost::Models::ApiResponse.new(
          data: [],
          status_code: 200,
          headers: {}
        ))
      end

      it "returns empty array" do
        result = client.search_postcode(city: city, street: street)
        expect(result).to eq([])
      end
    end

    context "when building number contains 'корпус'" do
      let(:formatted_building) { "3Е/4" }

      before do
        allow(api_service).to receive(:get).with(
          "/api/v1/business/geo-directory/postcode",
          { city: city, street: street, building: formatted_building, limit: limit }
        ).and_return(Belpost::Models::ApiResponse.new(
          data: api_response,
          status_code: 200,
          headers: {}
        ))
      end

      it "formats building number with 'корпус'" do
        result = client.search_postcode(city: city, street: street, building: "3Е корпус 4")
        expect(result).to eq(api_response)
        expect(api_service).to have_received(:get).with(
          "/api/v1/business/geo-directory/postcode",
          { city: city, street: street, building: formatted_building, limit: limit }
        )
      end

      it "formats building number with 'корп'" do
        result = client.search_postcode(city: city, street: street, building: "3Е корп 4")
        expect(result).to eq(api_response)
        expect(api_service).to have_received(:get).with(
          "/api/v1/business/geo-directory/postcode",
          { city: city, street: street, building: formatted_building, limit: limit }
        )
      end

      it "formats building number with 'кор'" do
        result = client.search_postcode(city: city, street: street, building: "3Е кор 4")
        expect(result).to eq(api_response)
        expect(api_service).to have_received(:get).with(
          "/api/v1/business/geo-directory/postcode",
          { city: city, street: street, building: formatted_building, limit: limit }
        )
      end

      it "formats building number with 'к'" do
        result = client.search_postcode(city: city, street: street, building: "3Е к 4")
        expect(result).to eq(api_response)
        expect(api_service).to have_received(:get).with(
          "/api/v1/business/geo-directory/postcode",
          { city: city, street: street, building: formatted_building, limit: limit }
        )
      end

      it "formats building number with different spacing" do
        result = client.search_postcode(city: city, street: street, building: "3Е  корпус  4")
        expect(result).to eq(api_response)
        expect(api_service).to have_received(:get).with(
          "/api/v1/business/geo-directory/postcode",
          { city: city, street: street, building: formatted_building, limit: limit }
        )
      end

      it "formats building number with different case" do
        result = client.search_postcode(city: city, street: street, building: "3Е КОРПУС 4")
        expect(result).to eq(api_response)
        expect(api_service).to have_received(:get).with(
          "/api/v1/business/geo-directory/postcode",
          { city: city, street: street, building: formatted_building, limit: limit }
        )
      end
    end

    context "when API returns 422 error" do
      before do
        allow(api_service).to receive(:get).and_raise(
          Belpost::InvalidRequestError.new(
            "The given data was invalid.",
            status_code: 422,
            response_body: {
              "message" => "The given data was invalid.",
              "errors" => {
                "search" => ["Поле city имеет ошибочный формат."]
              }
            }
          )
        )
      end

      it "raises InvalidRequestError with error details" do
        expect { client.search_postcode(city: city, street: street) }.to raise_error(
          Belpost::InvalidRequestError,
          "The given data was invalid."
        )
      end
    end

    context "when parameters are invalid" do
      it "raises ValidationError for empty city" do
        expect { client.search_postcode(city: "", street: street) }.to raise_error(
          Belpost::ValidationError,
          /City must be filled/
        )
      end

      it "raises ValidationError for nil city" do
        expect { client.search_postcode(city: nil, street: street) }.to raise_error(
          Belpost::ValidationError,
          /City must be filled/
        )
      end

      it "raises ValidationError for non-string city" do
        expect { client.search_postcode(city: 123, street: street) }.to raise_error(
          Belpost::ValidationError,
          /City must be a string/
        )
      end

      it "raises ValidationError for empty street" do
        expect { client.search_postcode(city: city, street: "") }.to raise_error(
          Belpost::ValidationError,
          /Street must be filled/
        )
      end

      it "raises ValidationError for nil street" do
        expect { client.search_postcode(city: city, street: nil) }.to raise_error(
          Belpost::ValidationError,
          /Street must be filled/
        )
      end

      it "raises ValidationError for non-string street" do
        expect { client.search_postcode(city: city, street: 123) }.to raise_error(
          Belpost::ValidationError,
          /Street must be a string/
        )
      end

      it "raises ValidationError for non-string building" do
        expect { client.search_postcode(city: city, street: street, building: 123) }.to raise_error(
          Belpost::ValidationError,
          /Building must be a string/
        )
      end

      it "raises ValidationError for limit less than 1" do
        expect { client.search_postcode(city: city, street: street, limit: 0) }.to raise_error(
          Belpost::ValidationError,
          /Limit must be between 1 and 200/
        )
      end

      it "raises ValidationError for limit greater than 200" do
        expect { client.search_postcode(city: city, street: street, limit: 201) }.to raise_error(
          Belpost::ValidationError,
          /Limit must be between 1 and 200/
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
        expect { client.search_postcode(city: city, street: street) }.to raise_error(
          Belpost::ApiError,
          "API Error"
        )
      end
    end
  end
end 