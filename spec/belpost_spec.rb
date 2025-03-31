# frozen_string_literal: true

require "spec_helper"
require "belpost"

RSpec.describe Belpost do
  before(:all) do
    # Убедимся, что тесты не зависят от реальных переменных окружения
    @original_api_url = ENV["BELPOST_API_URL"]
    ENV["BELPOST_API_URL"] = "https://api.belpost.by"
  end

  after(:all) do
    # Восстановим оригинальное значение
    ENV["BELPOST_API_URL"] = @original_api_url
  end

  it "has a version number" do
    expect(Belpost::VERSION).not_to be_nil
  end

  describe ".configure" do
    it "yields configuration to the block" do
      expect { |b| described_class.configure(&b) }.to yield_with_args(Belpost::Configuration)
    end

    it "sets configuration values" do
      described_class.configure do |config|
        config.jwt_token = "test-token"
        config.base_url = "https://test-api.belpost.by"
        config.timeout = 20
      end

      config = described_class.configuration
      expect(config.jwt_token).to eq("test-token")
      expect(config.base_url).to eq("https://test-api.belpost.by")
      expect(config.timeout).to eq(20)
    end
  end

  describe ".reset" do
    around do |example|
      # Сохраняем текущие значения
      old_api_url = ENV["BELPOST_API_URL"]
      old_jwt_token = ENV["BELPOST_JWT_TOKEN"]
      old_timeout = ENV["BELPOST_TIMEOUT"]
      
      # Устанавливаем значения для теста
      ENV["BELPOST_API_URL"] = "https://api.belpost.by"
      ENV.delete("BELPOST_JWT_TOKEN")
      ENV.delete("BELPOST_TIMEOUT")
      
      example.run
      
      # Восстанавливаем переменные среды
      ENV["BELPOST_API_URL"] = old_api_url
      ENV["BELPOST_JWT_TOKEN"] = old_jwt_token
      ENV["BELPOST_TIMEOUT"] = old_timeout
    end

    it "resets the configuration to environment values" do
      described_class.configure do |config|
        config.jwt_token = "test-token"
        config.base_url = "https://test-api.belpost.by"
        config.timeout = 20
      end

      described_class.reset
      
      config = described_class.configuration
      expect(config.base_url).to eq("https://api.belpost.by")
      expect(config.jwt_token).to be_nil
      expect(config.timeout).to eq(10)
    end
  end

  describe ".configuration" do
    it "returns the current configuration" do
      expect(described_class.configuration).to be_a(Belpost::Configuration)
    end

    it "returns the same configuration object on multiple calls" do
      config1 = described_class.configuration
      config2 = described_class.configuration
      expect(config1).to equal(config2)
    end
  end

  describe "error hierarchy" do
    it "has Error as the base error class" do
      expect(Belpost::Error.superclass).to eq(StandardError)
    end

    it "has specific error classes inheriting from Error" do
      expect(Belpost::ConfigurationError.superclass).to eq(Belpost::Error)
      expect(Belpost::ApiError.superclass).to eq(Belpost::Error)
      expect(Belpost::ValidationError.superclass).to eq(Belpost::Error)
      expect(Belpost::NetworkError.superclass).to eq(Belpost::Error)
      expect(Belpost::TimeoutError.superclass).to eq(Belpost::Error)
      expect(Belpost::RequestError.superclass).to eq(Belpost::Error)
      expect(Belpost::ParseError.superclass).to eq(Belpost::Error)
    end
  end
end
