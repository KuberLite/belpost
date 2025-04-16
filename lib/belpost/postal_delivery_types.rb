# frozen_string_literal: true

module Belpost
  # Module for managing postal delivery types in the Belpost system.
  # Provides a centralized way to handle and validate different types of postal deliveries.
  #
  # @example Validating a postal delivery type
  #   Belpost::PostalDeliveryTypes.valid?("ordered_small_package") # => true
  #
  # @example Getting all available types
  #   Belpost::PostalDeliveryTypes.all # => [:ordered_small_package, :letter_declare_value, ...]
  #
  # @example Getting a description for a type
  #   Belpost::PostalDeliveryTypes.description("ordered_small_package") # => "Заказной мелкий пакет республиканский"
  #
  # @note All types are frozen to prevent modification at runtime
  module PostalDeliveryTypes
    # Hash containing all valid postal delivery types with their Russian descriptions
    # @return [Hash<Symbol, String>] frozen hash of postal delivery types and their descriptions
    TYPES = {
      ordered_small_package: "Заказной мелкий пакет республиканский",
      letter_declare_value: "Письмо с объявленной ценностью республиканское",
      package: "Простая посылка республиканская (без ОЦ)",
      ems: "Республиканское отправление EMS",
      ordered_parcel_post: "Заказная бандероль республиканская",
      ordered_letter: "Заказное письмо республиканское",
      ordered_postcard: "Заказная почтовая карточка республиканская",
      small_package_declare_value: "Мелкий пакет с объявленной ценностью республиканский",
      package_declare_value: "Посылка с объявленной ценностью республиканская",
      ecommerce_economical: "Отправление E-commerce Эконом",
      ecommerce_standard: "Отправление E-commerce Стандарт",
      ecommerce_elite: "Отправление E-commerce Элит",
      ecommerce_express: "Отправление E-commerce Экспресс",
      ecommerce_light: "Отправление E-commerce Лайт",
      ecommerce_optima: "Отправление E-commerce Оптима"
    }.freeze

    # Checks if the given type is a valid postal delivery type
    # @param type [String, Symbol, nil] the type to validate
    # @return [Boolean] true if the type is valid, false otherwise
    def self.valid?(type)
      return false if type.nil?
      TYPES.key?(type.to_sym)
    rescue NoMethodError
      false
    end

    # Returns all valid postal delivery types
    # @return [Array<Symbol>] array of all valid postal delivery type symbols
    def self.all
      TYPES.keys
    end

    # Returns the Russian description for a given postal delivery type
    # @param type [String, Symbol] the type to get the description for
    # @return [String, nil] the description if the type is valid, nil otherwise
    def self.description(type)
      TYPES[type.to_sym]
    rescue NoMethodError
      nil
    end
  end
end