# frozen_string_literal: true

require "spec_helper"

RSpec.describe Belpost::Configuration do
  after do
    ENV.delete("BELPOST_API_URL")
    ENV.delete("BELPOST_JWT_TOKEN")
    ENV.delete("BELPOST_TIMEOUT")
  end

  describe "default values" do
    before do
      ENV["BELPOST_API_URL"] = "https://api.belpost.by"
      ENV["BELPOST_JWT_TOKEN"] = "test-token-from-env"
      ENV["BELPOST_TIMEOUT"] = "30"
    end

    it "loads values from environment variables" do
      config = described_class.new
      expect(config.base_url).to eq("https://api.belpost.by")
      expect(config.jwt_token).to eq("test-token-from-env")
      expect(config.timeout).to eq(30)
    end

    it "can be overridden with explicit values" do
      config = described_class.new
      config.base_url = "https://test-api.belpost.by"
      config.jwt_token = "override-token"
      config.timeout = 15

      expect(config.base_url).to eq("https://test-api.belpost.by")
      expect(config.jwt_token).to eq("override-token")
      expect(config.timeout).to eq(15)
    end
  end

  describe "environment fallbacks" do
    it "falls back to defaults when environment variables are not set" do
      config = described_class.new
      expect(config.base_url).to eq("https://api.belpost.by")
      expect(config.jwt_token).to be_nil
      expect(config.timeout).to eq(10)
    end

    it "falls back to default timeout when invalid value is provided" do
      ENV["BELPOST_TIMEOUT"] = "invalid"
      config = described_class.new
      expect(config.timeout).to eq(10)
    end
  end

  describe "#validate!" do
    context "when all required configuration is present" do
      before do
        ENV["BELPOST_API_URL"] = "https://api.belpost.by"
        ENV["BELPOST_JWT_TOKEN"] = "test-token"
      end

      it "does not raise an error" do
        config = described_class.new
        expect { config.validate! }.not_to raise_error
      end
    end

    context "when jwt_token is missing" do
      before do
        ENV["BELPOST_API_URL"] = "https://api.belpost.by"
      end

      it "raises a ConfigurationError" do
        config = described_class.new
        expect { config.validate! }.to raise_error(Belpost::ConfigurationError, "JWT token is required")
      end
    end

    context "when base_url is missing" do
      before do
        ENV.delete("BELPOST_API_URL")
        ENV["BELPOST_JWT_TOKEN"] = "test-token"
      end

      it "raises a ConfigurationError" do
        config = described_class.new
        config.base_url = nil
        expect { config.validate! }.to raise_error(Belpost::ConfigurationError, "Base URL is required")
      end
    end
  end

  describe "#to_h" do
    before do
      ENV["BELPOST_API_URL"] = "https://api.belpost.by"
      ENV["BELPOST_JWT_TOKEN"] = "test-token-from-env"
      ENV["BELPOST_TIMEOUT"] = "30"
    end

    it "returns a hash representation of the configuration" do
      config = described_class.new
      expect(config.to_h).to eq({
        base_url: "https://api.belpost.by",
        jwt_token: "test-token-from-env",
        timeout: 30
      })
    end

    it "includes explicit overrides in the hash" do
      config = described_class.new
      config.base_url = "https://test-api.belpost.by"
      config.jwt_token = "override-token"
      config.timeout = 15

      expect(config.to_h).to eq({
        base_url: "https://test-api.belpost.by",
        jwt_token: "override-token",
        timeout: 15
      })
    end
  end

  describe "#initialize_from_env" do
    context "when all environment variables are set" do
      before do
        ENV["BELPOST_API_URL"] = "https://api.belpost.by"
        ENV["BELPOST_JWT_TOKEN"] = "test-token-from-env"
        ENV["BELPOST_TIMEOUT"] = "30"
      end

      it "initializes values from environment variables" do
        config = described_class.new
        expect(config.base_url).to eq("https://api.belpost.by")
        expect(config.jwt_token).to eq("test-token-from-env")
        expect(config.timeout).to eq(30)
      end
    end

    context "when environment variables are missing" do
      it "uses default values" do
        config = described_class.new
        expect(config.base_url).to eq("https://api.belpost.by")
        expect(config.jwt_token).to be_nil
        expect(config.timeout).to eq(10)
      end
    end
  end
end 