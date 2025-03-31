# frozen_string_literal: true

RSpec.describe Belpost::Configuration do
  describe "default values" do
    let(:config) { described_class.new }

    around do |example|
      # Сохраняем текущие значения
      old_api_url = ENV["BELPOST_API_URL"]
      old_jwt_token = ENV["BELPOST_JWT_TOKEN"]
      old_timeout = ENV["BELPOST_TIMEOUT"]
      
      # Устанавливаем значения для теста
      ENV["BELPOST_API_URL"] = "https://api.belpost.by" # Обязательное значение
      ENV.delete("BELPOST_JWT_TOKEN")
      ENV.delete("BELPOST_TIMEOUT")
      
      example.run
      
      # Восстанавливаем переменные среды
      ENV["BELPOST_API_URL"] = old_api_url
      ENV["BELPOST_JWT_TOKEN"] = old_jwt_token
      ENV["BELPOST_TIMEOUT"] = old_timeout
    end

    it "has required value for base_url" do
      expect(config.base_url).to eq("https://api.belpost.by")
    end

    it "has default value for timeout" do
      expect(config.timeout).to eq(10)
    end

    it "has nil value for jwt_token" do
      expect(config.jwt_token).to be_nil
    end
  end

  describe "environment variables" do
    context "when environment variables are set" do
      around do |example|
        # Сохраняем текущие значения
        old_api_url = ENV["BELPOST_API_URL"]
        old_jwt_token = ENV["BELPOST_JWT_TOKEN"]
        old_timeout = ENV["BELPOST_TIMEOUT"]
        
        # Устанавливаем тестовые значения
        ENV["BELPOST_API_URL"] = "https://test-api.belpost.by"
        ENV["BELPOST_JWT_TOKEN"] = "test-token"
        ENV["BELPOST_TIMEOUT"] = "30"
        
        example.run
        
        # Восстанавливаем переменные среды
        ENV["BELPOST_API_URL"] = old_api_url
        ENV["BELPOST_JWT_TOKEN"] = old_jwt_token
        ENV["BELPOST_TIMEOUT"] = old_timeout
      end

      it "reads JWT token from environment" do
        config = described_class.new
        expect(config.jwt_token).to eq("test-token")
      end

      it "reads base URL from environment" do
        config = described_class.new
        expect(config.base_url).to eq("https://test-api.belpost.by")
      end

      it "reads timeout from environment and converts to integer" do
        config = described_class.new
        expect(config.timeout).to eq(30)
      end
    end

    context "when environment variables are not set" do
      around do |example|
        # Сохраняем текущие значения
        old_api_url = ENV["BELPOST_API_URL"]
        old_jwt_token = ENV["BELPOST_JWT_TOKEN"]
        old_timeout = ENV["BELPOST_TIMEOUT"]
        
        # Устанавливаем необходимый минимум
        ENV["BELPOST_API_URL"] = "https://api.belpost.by" # Обязательное значение
        ENV.delete("BELPOST_JWT_TOKEN")
        ENV.delete("BELPOST_TIMEOUT")
        
        example.run
        
        # Восстанавливаем переменные среды
        ENV["BELPOST_API_URL"] = old_api_url
        ENV["BELPOST_JWT_TOKEN"] = old_jwt_token
        ENV["BELPOST_TIMEOUT"] = old_timeout
      end

      it "uses default values where applicable" do
        config = described_class.new
        expect(config.base_url).to eq("https://api.belpost.by")
        expect(config.jwt_token).to be_nil
        expect(config.timeout).to eq(10)
      end
      
      it "raises KeyError when BELPOST_API_URL is missing" do
        ENV.delete("BELPOST_API_URL")
        expect { described_class.new }.to raise_error(KeyError, /BELPOST_API_URL/)
      end
    end
  end

  describe "configuration via setter methods" do
    let(:config) do
      # Установим минимальное значение для создания объекта
      old_api_url = ENV["BELPOST_API_URL"]
      begin
        ENV["BELPOST_API_URL"] = "https://api.belpost.by"
        described_class.new
      ensure
        ENV["BELPOST_API_URL"] = old_api_url
      end
    end

    it "allows setting jwt_token" do
      config.jwt_token = "new-token"
      expect(config.jwt_token).to eq("new-token")
    end

    it "allows setting base_url" do
      config.base_url = "https://new-api.belpost.by"
      expect(config.base_url).to eq("https://new-api.belpost.by")
    end

    it "allows setting timeout" do
      config.timeout = 20
      expect(config.timeout).to eq(20)
    end
  end

  describe "using configure block" do
    around do |example|
      old_api_url = ENV["BELPOST_API_URL"]
      ENV["BELPOST_API_URL"] = "https://api.belpost.by"
      example.run
      ENV["BELPOST_API_URL"] = old_api_url
    end
    
    it "configures via block" do
      config = nil
      Belpost.configure do |c|
        c.jwt_token = "token-from-block"
        c.base_url = "https://block-api.belpost.by"
        c.timeout = 15
        config = c
      end

      expect(config.jwt_token).to eq("token-from-block")
      expect(config.base_url).to eq("https://block-api.belpost.by")
      expect(config.timeout).to eq(15)
    end
  end

  describe ".reset" do
    around do |example|
      # Сохраняем текущие значения
      old_api_url = ENV["BELPOST_API_URL"]
      old_jwt_token = ENV["BELPOST_JWT_TOKEN"]
      old_timeout = ENV["BELPOST_TIMEOUT"]
      
      # Устанавливаем значения для теста
      ENV["BELPOST_API_URL"] = "https://api.belpost.by" # Обязательное значение
      ENV.delete("BELPOST_JWT_TOKEN")
      ENV.delete("BELPOST_TIMEOUT")
      
      example.run
      
      # Восстанавливаем переменные среды
      ENV["BELPOST_API_URL"] = old_api_url
      ENV["BELPOST_JWT_TOKEN"] = old_jwt_token
      ENV["BELPOST_TIMEOUT"] = old_timeout
    end

    it "resets configuration to environment values" do
      config = Belpost.configuration
      config.jwt_token = "custom-token"
      config.base_url = "https://custom-api.belpost.by"
      config.timeout = 25

      Belpost.reset
      new_config = Belpost.configuration

      expect(new_config.jwt_token).to be_nil
      expect(new_config.base_url).to eq("https://api.belpost.by")
      expect(new_config.timeout).to eq(10)
    end
  end
end 