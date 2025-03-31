# frozen_string_literal: true

RSpec.describe Belpost::Validation::ParcelSchema do
  describe "valid data" do
    let(:valid_data) do
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

    it "validates correct data successfully" do
      result = described_class.call(valid_data)
      expect(result).to be_success
    end

    it "validates with addons" do
      data = valid_data.dup
      data[:addons] = {
        declared_value: {
          currency: "BYN",
          value: 100.0
        },
        simple_notification: true,
        email_notification: true
      }
      result = described_class.call(data)
      expect(result).to be_success
    end

    it "validates with customs declaration" do
      data = valid_data.dup
      data[:parcel][:arrival][:country] = "DE"
      data[:cp72] = {
        category: "gift",
        price: {
          currency: "EUR",
          value: 50.0
        },
        items: [
          {
            name: "Book",
            local: "Книга",
            unit: {
              local: "ШТ",
              en: "PCS"
            },
            count: 1,
            weight: 500,
            price: {
              currency: "EUR",
              value: 50.0
            },
            country: "BY"
          }
        ]
      }
      result = described_class.call(data)
      expect(result).to be_success
    end
  end

  describe "invalid data" do
    let(:valid_data) do
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

    # Вспомогательный метод для проверки наличия ошибки по пути в хэше ошибок
    def expect_error_at_path(errors_hash, path)
      current = errors_hash
      # Проходим по всем ключам в пути, кроме последнего
      path[0..-2].each do |key|
        expect(current).to have_key(key)
        current = current[key]
      end
      # Проверяем наличие последнего ключа
      expect(current).to have_key(path.last)
    end

    it "rejects invalid parcel type" do
      data = valid_data.dup
      data[:parcel][:type] = "invalid"
      result = described_class.call(data)
      expect(result).not_to be_success
      expect_error_at_path(result.errors.to_h, [:parcel, :type])
    end

    it "rejects negative weight" do
      data = valid_data.dup
      data[:parcel][:measures][:weight] = -10
      result = described_class.call(data)
      expect(result).not_to be_success
      expect_error_at_path(result.errors.to_h, [:parcel, :measures, :weight])
    end

    it "rejects non-BY departure country" do
      data = valid_data.dup
      data[:parcel][:departure][:country] = "US"
      result = described_class.call(data)
      expect(result).not_to be_success
      expect_error_at_path(result.errors.to_h, [:parcel, :departure, :country])
    end

    it "rejects invalid sender type" do
      data = valid_data.dup
      data[:sender][:type] = "invalid"
      result = described_class.call(data)
      expect(result).not_to be_success
      expect_error_at_path(result.errors.to_h, [:sender, :type])
    end

    it "rejects empty organization name for legal person" do
      data = valid_data.dup
      data[:sender][:info][:organization_name] = ""
      result = described_class.call(data)
      expect(result).not_to be_success
      expect_error_at_path(result.errors.to_h, [:sender, :info, :organization_name])
    end

    it "rejects missing required sender location fields" do
      data = valid_data.dup
      data[:sender][:location].delete(:code)
      result = described_class.call(data)
      expect(result).not_to be_success
      expect_error_at_path(result.errors.to_h, [:sender, :location, :code])
    end

    it "rejects invalid customs declaration category" do
      data = valid_data.dup
      data[:parcel][:arrival][:country] = "DE"
      data[:cp72] = {
        category: "invalid",
        price: {
          currency: "EUR",
          value: 50.0
        }
      }
      result = described_class.call(data)
      expect(result).not_to be_success
      expect_error_at_path(result.errors.to_h, [:cp72, :category])
    end

    it "rejects non-positive values in cash on delivery" do
      data = valid_data.dup
      data[:addons] = {
        cash_on_delivery: {
          currency: "BYN",
          value: 0
        }
      }
      result = described_class.call(data)
      expect(result).not_to be_success
      expect_error_at_path(result.errors.to_h, [:addons, :cash_on_delivery, :value])
    end
  end
end 