# frozen_string_literal: true

RSpec.describe Belpost::ApiService do
  before(:all) do
    @original_api_url = ENV["BELPOST_API_URL"]
    ENV["BELPOST_API_URL"] = "https://api.belpost.by"
  end

  after(:all) do
    ENV["BELPOST_API_URL"] = @original_api_url
  end

  let(:base_url) { "https://api.belpost.by" }
  let(:jwt_token) { "test-jwt-token" }
  let(:timeout) { 30 }
  let(:logger) { instance_double(Logger, info: nil, debug: nil, error: nil) }
  let(:service) { described_class.new(base_url: base_url, jwt_token: jwt_token, timeout: timeout, logger: logger) }

  let(:http_client) { instance_double(Net::HTTP) }

  before do
    allow(Net::HTTP).to receive(:new).and_return(http_client)
    allow(http_client).to receive(:use_ssl=)
    allow(http_client).to receive(:read_timeout=)
  end

  describe "#get" do
    let(:endpoint) { "/api/v1/test" }
    let(:uri) { URI("#{base_url}#{endpoint}") }

    let(:success_response) do
      response = double("HTTP Response")
      allow(response).to receive(:code).and_return("200")
      allow(response).to receive(:body).and_return('{"key":"value"}')
      allow(response).to receive(:to_hash).and_return({ "content-type" => ["application/json"] })
      response
    end

    it "makes a GET request to the specified endpoint" do
      expect(http_client).to receive(:request).and_return(success_response)

      service.get(endpoint)
    end

    it "sets the correct headers" do
      expect(http_client).to receive(:request) do |req|
        expect(req["Authorization"]).to eq("Bearer #{jwt_token}")
        expect(req["Accept"]).to eq("application/json")
        expect(req["Content-Type"]).to eq("application/json")
        success_response
      end

      service.get(endpoint)
    end

    it "returns an ApiResponse with the correct data" do
      expect(http_client).to receive(:request).and_return(success_response)

      result = service.get(endpoint)

      expect(result).to be_a(Belpost::Models::ApiResponse)
      expect(result.data).to eq({ "key" => "value" })
      expect(result.status_code).to eq(200)
    end

    context "when an HTTP error occurs" do
      it "retries the request and raises RequestError after max retries" do
        allow(http_client).to receive(:request).and_raise(Net::ReadTimeout.new("Request timed out"))

        expect { service.get(endpoint) }.to raise_error(Belpost::RequestError, /Request timed out/)
      end
    end

    context "when the server returns an error status" do
      let(:error_response) do
        response = double("HTTP Response")
        allow(response).to receive(:code).and_return("400")
        allow(response).to receive(:body).and_return('{"error":"Bad Request"}')
        allow(response).to receive(:to_hash).and_return({ "content-type" => ["application/json"] })
        response
      end

      it "raises a network error with the error message" do
        allow(http_client).to receive(:request).and_return(error_response)

        expect { service.get(endpoint) }.to raise_error(Belpost::NetworkError, /Network error: Invalid request/)
      end
    end

    context "when the response is not valid JSON" do
      let(:invalid_json_response) do
        response = double("HTTP Response")
        allow(response).to receive(:code).and_return("200")
        allow(response).to receive(:body).and_return('{"invalid":json}')
        allow(response).to receive(:to_hash).and_return({ "content-type" => ["application/json"] })
        response
      end

      it "raises ParseError" do
        allow(http_client).to receive(:request).and_return(invalid_json_response)

        expect { service.get(endpoint) }.to raise_error(Belpost::ParseError, /Failed to parse JSON/)
      end
    end
  end

  describe "#post" do
    let(:endpoint) { "/api/v1/test" }
    let(:uri) { URI("#{base_url}#{endpoint}") }
    let(:data) { { test: "data" } }

    let(:success_response) do
      response = double("HTTP Response")
      allow(response).to receive(:code).and_return("200")
      allow(response).to receive(:body).and_return('{"key":"value"}')
      allow(response).to receive(:to_hash).and_return({ "content-type" => ["application/json"] })
      response
    end

    it "makes a POST request to the specified endpoint with the provided data" do
      expect(http_client).to receive(:request) do |req|
        expect(req.method).to eq("POST")
        expect(req.path).to include(endpoint)
        expect(req.body).to eq(data.to_json)
        success_response
      end

      service.post(endpoint, data)
    end

    it "sets the correct headers and body" do
      expect(http_client).to receive(:request) do |req|
        expect(req["Authorization"]).to eq("Bearer #{jwt_token}")
        expect(req["Accept"]).to eq("application/json")
        expect(req["Content-Type"]).to eq("application/json")
        expect(req.body).to eq(data.to_json)
        success_response
      end

      service.post(endpoint, data)
    end

    it "returns an ApiResponse with the correct data" do
      allow(http_client).to receive(:request).and_return(success_response)

      result = service.post(endpoint, data)

      expect(result).to be_a(Belpost::Models::ApiResponse)
      expect(result.data).to eq({ "key" => "value" })
      expect(result.status_code).to eq(200)
    end

    context "when an HTTP error occurs" do
      it "retries the request and raises RequestError after max retries" do
        allow(http_client).to receive(:request).and_raise(Net::ReadTimeout.new("Request timed out"))

        expect { service.post(endpoint, data) }.to raise_error(Belpost::RequestError, /Request timed out/)
      end
    end

    context "when the server returns an error status" do
      let(:error_response) do
        response = double("HTTP Response")
        allow(response).to receive(:code).and_return("400")
        allow(response).to receive(:body).and_return('{"error":"Bad Request"}')
        allow(response).to receive(:to_hash).and_return({ "content-type" => ["application/json"] })
        response
      end

      it "raises a network error with the error message" do
        allow(http_client).to receive(:request).and_return(error_response)

        expect { service.post(endpoint, data) }.to raise_error(Belpost::NetworkError, /Network error: Invalid request/)
      end
    end
  end

  describe "#put" do
    let(:endpoint) { "/api/v1/test" }
    let(:uri) { URI("#{base_url}#{endpoint}") }
    let(:data) { { test: "data" } }

    let(:success_response) do
      response = double("HTTP Response")
      allow(response).to receive(:code).and_return("200")
      allow(response).to receive(:body).and_return('{"key":"value"}')
      allow(response).to receive(:to_hash).and_return({ "content-type" => ["application/json"] })
      response
    end

    it "makes a PUT request to the specified endpoint with the provided data" do
      expect(http_client).to receive(:request) do |req|
        expect(req.method).to eq("PUT")
        expect(req.path).to include(endpoint)
        expect(req.body).to eq(data.to_json)
        success_response
      end

      service.put(endpoint, data)
    end

    it "sets the correct headers and body" do
      expect(http_client).to receive(:request) do |req|
        expect(req["Authorization"]).to eq("Bearer #{jwt_token}")
        expect(req["Accept"]).to eq("application/json")
        expect(req["Content-Type"]).to eq("application/json")
        expect(req.body).to eq(data.to_json)
        success_response
      end

      service.put(endpoint, data)
    end

    it "returns an ApiResponse with the correct data" do
      allow(http_client).to receive(:request).and_return(success_response)

      result = service.put(endpoint, data)

      expect(result).to be_a(Belpost::Models::ApiResponse)
      expect(result.data).to eq({ "key" => "value" })
      expect(result.status_code).to eq(200)
    end
  end

  describe "#delete" do
    let(:endpoint) { "/api/v1/test" }
    let(:uri) { URI("#{base_url}#{endpoint}") }

    let(:success_response) do
      response = double("HTTP Response")
      allow(response).to receive(:code).and_return("200")
      allow(response).to receive(:body).and_return('{"key":"value"}')
      allow(response).to receive(:to_hash).and_return({ "content-type" => ["application/json"] })
      response
    end

    it "makes a DELETE request to the specified endpoint" do
      expect(http_client).to receive(:request) do |req|
        expect(req.method).to eq("DELETE")
        expect(req.path).to include(endpoint)
        success_response
      end

      service.delete(endpoint)
    end

    it "sets the correct headers" do
      expect(http_client).to receive(:request) do |req|
        expect(req["Authorization"]).to eq("Bearer #{jwt_token}")
        expect(req["Accept"]).to eq("application/json")
        expect(req["Content-Type"]).to eq("application/json")
        success_response
      end

      service.delete(endpoint)
    end

    it "returns an ApiResponse with the correct data" do
      allow(http_client).to receive(:request).and_return(success_response)

      result = service.delete(endpoint)

      expect(result).to be_a(Belpost::Models::ApiResponse)
      expect(result.data).to eq({ "key" => "value" })
      expect(result.status_code).to eq(200)
    end
  end
end 