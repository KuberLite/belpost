# frozen_string_literal: true

RSpec.describe Belpost::Models::ParcelBuilder do
  let(:builder) { described_class.new }

  describe "#initialize" do
    it "creates a builder with default values" do
      expect(builder.instance_variable_get(:@data)).to include(
        parcel: hash_including(
          type: "package",
          attachment_type: "products",
          measures: {},
          departure: hash_including(country: "BY", place: "post_office"),
          arrival: hash_including(place: "post_office")
        )
      )
    end
  end

  describe "basic parcel configuration" do
    it "sets parcel type" do
      builder.with_type("package")
      expect(builder.instance_variable_get(:@data)[:parcel][:type]).to eq("package")
    end

    it "sets attachment type" do
      builder.with_attachment_type("registered")
      expect(builder.instance_variable_get(:@data)[:parcel][:attachment_type]).to eq("registered")
    end

    it "sets weight" do
      builder.with_weight(1500)
      expect(builder.instance_variable_get(:@data)[:parcel][:measures][:weight]).to eq(1500)
    end

    it "sets dimensions" do
      builder.with_dimensions(30, 20, 10)
      data = builder.instance_variable_get(:@data)
      expect(data[:parcel][:measures][:long]).to eq(30)
      expect(data[:parcel][:measures][:width]).to eq(20)
      expect(data[:parcel][:measures][:height]).to eq(10)
    end

    it "sets destination country" do
      builder.to_country("DE")
      expect(builder.instance_variable_get(:@data)[:parcel][:arrival][:country]).to eq("DE")
    end
  end

  describe "addons configuration" do
    it "sets declared value" do
      builder.with_declared_value(100)
      expect(builder.instance_variable_get(:@data)[:addons][:declared_value]).to eq(
        { currency: "BYN", value: 100.0 }
      )
    end

    it "sets declared value with custom currency" do
      builder.with_declared_value(100, "EUR")
      expect(builder.instance_variable_get(:@data)[:addons][:declared_value]).to eq(
        { currency: "EUR", value: 100.0 }
      )
    end

    it "sets cash on delivery" do
      builder.with_declared_value(100)
      builder.with_cash_on_delivery(50)
      expect(builder.instance_variable_get(:@data)[:addons][:cash_on_delivery]).to eq(
        { currency: "BYN", value: 50.0 }
      )
    end

    it "adds service" do
      builder.add_service("sms_notification")
      expect(builder.instance_variable_get(:@data)[:addons][:sms_notification]).to be(true)
    end

    it "adds service with value" do
      builder.add_service("insurance", 100)
      expect(builder.instance_variable_get(:@data)[:addons][:insurance]).to eq(100)
    end
  end

  describe "sender configuration" do
    it "sets legal person sender" do
      builder.from_legal_person("ООО \"Компания\"")
      data = builder.instance_variable_get(:@data)
      expect(data[:sender][:type]).to eq("legal_person")
      expect(data[:sender][:info][:organization_name]).to eq("ООО \"Компания\"")
    end

    it "sets sole proprietor sender" do
      builder.from_sole_proprietor("ИП Иванов И.И.")
      data = builder.instance_variable_get(:@data)
      expect(data[:sender][:type]).to eq("sole_proprietor")
      expect(data[:sender][:info][:organization_name]).to eq("ИП Иванов И.И.")
    end

    it "sets sender details" do
      builder.with_sender_details(
        taxpayer_number: "123456789",
        bank: "Беларусбанк",
        iban: "BY00UNBS00000000000000000000",
        bic: "UNBSBY2X"
      )
      data = builder.instance_variable_get(:@data)
      expect(data[:sender][:info][:taxpayer_number]).to eq("123456789")
      expect(data[:sender][:info][:bank]).to eq("Беларусбанк")
      expect(data[:sender][:info][:IBAN]).to eq("BY00UNBS00000000000000000000")
      expect(data[:sender][:info][:BIC]).to eq("UNBSBY2X")
    end

    it "sets sender location" do
      builder.with_sender_location(
        postal_code: "220000",
        region: "Минская",
        district: "Минский",
        locality_type: "city",
        locality_name: "Минск",
        road_type: "street",
        road_name: "Независимости",
        building: "10",
        housing: "2",
        apartment: "100"
      )
      data = builder.instance_variable_get(:@data)
      expect(data[:sender][:location][:code]).to eq("220000")
      expect(data[:sender][:location][:region]).to eq("Минская")
      expect(data[:sender][:location][:district]).to eq("Минский")
      expect(data[:sender][:location][:locality][:type]).to eq("city")
      expect(data[:sender][:location][:locality][:name]).to eq("Минск")
      expect(data[:sender][:location][:road][:type]).to eq("street")
      expect(data[:sender][:location][:road][:name]).to eq("Независимости")
      expect(data[:sender][:location][:building]).to eq("10")
      expect(data[:sender][:location][:housing]).to eq("2")
      expect(data[:sender][:location][:apartment]).to eq("100")
    end

    it "sets sender contact information" do
      builder.with_sender_contact(email: "sender@example.com", phone: "375291234567")
      data = builder.instance_variable_get(:@data)
      expect(data[:sender][:email]).to eq("sender@example.com")
      expect(data[:sender][:phone]).to eq("375291234567")
    end
  end

  describe "recipient configuration" do
    it "sets natural person recipient" do
      builder.to_natural_person(
        first_name: "Иван",
        last_name: "Иванов",
        second_name: "Иванович"
      )
      data = builder.instance_variable_get(:@data)
      expect(data[:recipient][:type]).to eq("natural_person")
      expect(data[:recipient][:info][:first_name]).to eq("Иван")
      expect(data[:recipient][:info][:last_name]).to eq("Иванов")
      expect(data[:recipient][:info][:second_name]).to eq("Иванович")
    end

    it "sets legal person recipient" do
      builder.to_legal_person("ООО \"Получатель\"")
      data = builder.instance_variable_get(:@data)
      expect(data[:recipient][:type]).to eq("legal_person")
      expect(data[:recipient][:info][:organization_name]).to eq("ООО \"Получатель\"")
    end

    it "sets recipient location" do
      builder.with_recipient_location(
        postal_code: "220000",
        region: "Минская",
        district: "Минский",
        locality_type: "city",
        locality_name: "Минск",
        road_type: "street",
        road_name: "Независимости",
        building: "10",
        housing: "2",
        apartment: "100"
      )
      data = builder.instance_variable_get(:@data)
      expect(data[:recipient][:location][:code]).to eq("220000")
      expect(data[:recipient][:location][:region]).to eq("Минская")
      expect(data[:recipient][:location][:district]).to eq("Минский")
      expect(data[:recipient][:location][:locality][:type]).to eq("city")
      expect(data[:recipient][:location][:locality][:name]).to eq("Минск")
      expect(data[:recipient][:location][:road][:type]).to eq("street")
      expect(data[:recipient][:location][:road][:name]).to eq("Независимости")
      expect(data[:recipient][:location][:building]).to eq("10")
      expect(data[:recipient][:location][:housing]).to eq("2")
      expect(data[:recipient][:location][:apartment]).to eq("100")
    end

    it "sets foreign recipient location" do
      builder.with_foreign_recipient_location(
        postal_code: "10115",
        locality: "Berlin",
        address: "Alexanderplatz 1"
      )
      data = builder.instance_variable_get(:@data)
      expect(data[:recipient][:location][:code]).to eq("10115")
      expect(data[:recipient][:location][:locality]).to eq("Berlin")
      expect(data[:recipient][:location][:address]).to eq("Alexanderplatz 1")
    end

    it "sets recipient contact information" do
      builder.with_recipient_contact(email: "recipient@example.com", phone: "375297654321")
      data = builder.instance_variable_get(:@data)
      expect(data[:recipient][:email]).to eq("recipient@example.com")
      expect(data[:recipient][:phone]).to eq("375297654321")
    end
  end

  describe "customs declaration" do
    it "sets customs declaration" do
      customs_declaration = Belpost::Models::CustomsDeclaration.new
      customs_declaration.set_category("gift")

      builder.with_customs_declaration(customs_declaration)
      data = builder.instance_variable_get(:@data)
      expect(data[:cp72]).to include(category: "gift")
    end
  end

  describe "#build" do
    context "when all required fields are set" do
      let(:builder) do
        described_class.new
          .with_type("package")
          .with_weight(1500)
          .to_country("BY")
          .from_legal_person("ООО \"Компания\"")
          .with_sender_location(
            postal_code: "220000",
            region: "Минская",
            district: "Минский",
            locality_type: "city",
            locality_name: "Минск",
            road_type: "street",
            road_name: "Независимости",
            building: "10"
          )
          .to_natural_person(first_name: "Иван", last_name: "Иванов")
          .with_recipient_contact(phone: "375297654321")
      end

      it "returns the built data" do
        data = builder.build
        expect(data[:parcel][:measures][:weight]).to eq(1500)
        expect(data[:parcel][:arrival][:country]).to eq("BY")
        expect(data[:sender][:type]).to eq("legal_person")
        expect(data[:recipient][:type]).to eq("natural_person")
      end
    end

    context "when all required fields are set for international parcel" do
      let(:customs_declaration) do
        declaration = Belpost::Models::CustomsDeclaration.new
        declaration.set_category("gift")
        declaration
      end
      
      let(:builder) do
        described_class.new
          .with_type("package")
          .with_weight(1500)
          .to_country("DE")
          .from_legal_person("ООО \"Компания\"")
          .with_sender_location(
            postal_code: "220000",
            region: "Минская",
            district: "Минский",
            locality_type: "city",
            locality_name: "Минск",
            road_type: "street",
            road_name: "Независимости",
            building: "10"
          )
          .to_natural_person(first_name: "Иван", last_name: "Иванов")
          .with_recipient_contact(phone: "375297654321")
          .with_customs_declaration(customs_declaration)
      end

      it "returns the built data for international parcel" do
        data = builder.build
        expect(data[:parcel][:measures][:weight]).to eq(1500)
        expect(data[:parcel][:arrival][:country]).to eq("DE")
        expect(data[:sender][:type]).to eq("legal_person")
        expect(data[:recipient][:type]).to eq("natural_person")
        expect(data[:cp72]).to include(category: "gift")
      end
    end

    context "when required fields are missing" do
      it "raises an error when weight is missing" do
        builder
          .from_legal_person("ООО \"Компания\"")
          .to_natural_person(first_name: "Иван", last_name: "Иванов")
        expect { builder.build }.to raise_error(Belpost::ValidationError, /weight/i)
      end

      it "raises an error when sender type is missing" do
        builder
          .with_weight(1500)
          .to_natural_person(first_name: "Иван", last_name: "Иванов")
        expect { builder.build }.to raise_error(Belpost::ValidationError, /sender type/i)
      end

      it "raises an error when recipient type is missing" do
        builder
          .with_weight(1500)
          .from_legal_person("ООО \"Компания\"")
        expect { builder.build }.to raise_error(Belpost::ValidationError, /recipient type/i)
      end
    end

    context "with business logic validations" do
      it "raises an error when cash on delivery without declared value" do
        builder
          .with_weight(1500)
          .from_legal_person("ООО \"Компания\"")
          .to_natural_person(first_name: "Иван", last_name: "Иванов")
          .with_cash_on_delivery(50)
        expect { builder.build }.to raise_error(Belpost::ValidationError, /declared value/i)
      end

      it "raises an error for international parcel without customs declaration" do
        builder
          .with_weight(1500)
          .to_country("DE")
          .from_legal_person("ООО \"Компания\"")
          .to_natural_person(first_name: "Иван", last_name: "Иванов")
          .with_recipient_contact(phone: "375297654321")
        expect { builder.build }.to raise_error(Belpost::ValidationError, /customs declaration/i)
      end
    end
  end

  describe "fluent interface" do
    it "supports method chaining" do
      result = builder
        .with_type("package")
        .with_weight(1500)
        .from_legal_person("ООО \"Компания\"")
        .to_natural_person(first_name: "Иван", last_name: "Иванов")

      expect(result).to be_an_instance_of(described_class)
    end
  end
end 