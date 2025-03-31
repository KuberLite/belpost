# frozen_string_literal: true

module Belpost
  module Models
    class ParcelBuilder
      def initialize
        @data = {
          parcel: {
            type: "package",
            attachment_type: "products",
            measures: {},
            departure: {
              country: "BY",
              place: "post_office"
            },
            arrival: {
              place: "post_office"
            }
          },
          addons: {},
          sender: {
            info: {},
            location: {}
          },
          recipient: {
            info: {},
            location: {}
          }
        }
      end

      # Основные параметры посылки
      def with_type(type)
        @data[:parcel][:type] = type
        self
      end

      def with_attachment_type(attachment_type)
        @data[:parcel][:attachment_type] = attachment_type
        self
      end

      def with_weight(weight_in_grams)
        @data[:parcel][:measures][:weight] = weight_in_grams
        self
      end

      def with_dimensions(length, width, height)
        @data[:parcel][:measures][:long] = length
        @data[:parcel][:measures][:width] = width
        @data[:parcel][:measures][:height] = height
        self
      end

      def to_country(country_code)
        @data[:parcel][:arrival][:country] = country_code
        self
      end

      # Дополнительные сервисы
      def with_declared_value(value, currency = "BYN")
        @data[:addons][:declared_value] = {
          currency: currency,
          value: value.to_f
        }
        self
      end

      def with_cash_on_delivery(value, currency = "BYN")
        @data[:addons][:cash_on_delivery] = {
          currency: currency,
          value: value.to_f
        }
        self
      end

      def add_service(service_name, value = true)
        @data[:addons][service_name.to_sym] = value
        self
      end

      # Отправитель
      def from_legal_person(organization_name)
        @data[:sender][:type] = "legal_person"
        @data[:sender][:info][:organization_name] = organization_name
        self
      end

      def from_sole_proprietor(organization_name)
        @data[:sender][:type] = "sole_proprietor"
        @data[:sender][:info][:organization_name] = organization_name
        self
      end

      def with_sender_details(taxpayer_number: nil, bank: nil, iban: nil, bic: nil)
        @data[:sender][:info][:taxpayer_number] = taxpayer_number if taxpayer_number
        @data[:sender][:info][:bank] = bank if bank
        @data[:sender][:info][:IBAN] = iban if iban
        @data[:sender][:info][:BIC] = bic if bic
        self
      end

      def with_sender_location(postal_code:, region:, district:, locality_type:, locality_name:, road_type:, road_name:, building:, housing: nil, apartment: nil)
        @data[:sender][:location] = {
          code: postal_code,
          region: region,
          district: district,
          locality: {
            type: locality_type,
            name: locality_name
          },
          road: {
            type: road_type,
            name: road_name
          },
          building: building,
          housing: housing,
          apartment: apartment
        }.compact
        self
      end

      def with_sender_contact(email:, phone:)
        @data[:sender][:email] = email
        @data[:sender][:phone] = phone
        self
      end

      # Получатель
      def to_natural_person(first_name:, last_name:, second_name: nil)
        @data[:recipient][:type] = "natural_person"
        @data[:recipient][:info] = {
          first_name: first_name,
          last_name: last_name,
          second_name: second_name
        }.compact
        self
      end

      def to_legal_person(organization_name)
        @data[:recipient][:type] = "legal_person"
        @data[:recipient][:info] = {
          organization_name: organization_name
        }
        self
      end

      def with_recipient_location(postal_code:, region:, district:, locality_type:, locality_name:, road_type:, road_name:, building:, housing: nil, apartment: nil)
        @data[:recipient][:location] = {
          code: postal_code,
          region: region,
          district: district,
          locality: {
            type: locality_type,
            name: locality_name
          },
          road: {
            type: road_type,
            name: road_name
          },
          building: building,
          housing: housing,
          apartment: apartment
        }.compact
        self
      end

      def with_foreign_recipient_location(postal_code:, locality:, address:)
        @data[:recipient][:location] = {
          code: postal_code,
          locality: locality,
          address: address
        }
        self
      end

      def with_recipient_contact(email: nil, phone:)
        @data[:recipient][:email] = email
        @data[:recipient][:phone] = phone
        self
      end

      # Таможенная декларация
      def with_customs_declaration(customs_declaration)
        @data[:cp72] = customs_declaration.to_h
        self
      end

      def build
        validate!
        @data
      end

      private

      def validate!
        # Проверка обязательных полей
        raise ValidationError, "Weight is required" unless @data.dig(:parcel, :measures, :weight)
        raise ValidationError, "Sender type is required" unless @data.dig(:sender, :type)
        raise ValidationError, "Recipient type is required" unless @data.dig(:recipient, :type)

        # Проверка логики
        if @data.dig(:addons, :cash_on_delivery) && !@data.dig(:addons, :declared_value)
          raise ValidationError, "Declared value is required when cash on delivery is set"
        end

        # Проверка международных отправлений
        if @data.dig(:parcel, :arrival, :country) != "BY"
          if @data[:cp72].nil? || @data[:cp72].empty?
            raise ValidationError, "Customs declaration is required for international parcels"
          end
        end
      end
    end
  end
end 