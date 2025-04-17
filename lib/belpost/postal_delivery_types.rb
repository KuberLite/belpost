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

    # Validation rules for each postal delivery type
    # @return [Hash<Symbol, Hash>] frozen hash of validation rules for each type
    VALIDATION_RULES = {
      ecommerce_economical: {
        negotiated_rate: false,
        declared_value: [true, false],
        partial_receipt: false,
        postal_items_in_ops: true
      },
      ecommerce_standard: {
        negotiated_rate: false,
        declared_value: [true, false],
        partial_receipt: false,
        postal_items_in_ops: [true, false]
      },
      ecommerce_elite: {
        negotiated_rate: false,
        declared_value: [true, false],
        partial_receipt: false,
        postal_items_in_ops: [true, false]
      },
      ecommerce_express: {
        negotiated_rate: false,
        declared_value: [true, false],
        partial_receipt: false,
        postal_items_in_ops: [true, false]
      },
      ecommerce_light: {
        negotiated_rate: false,
        declared_value: [true, false],
        partial_receipt: false,
        postal_items_in_ops: true
      },
      ecommerce_optima: {
        negotiated_rate: false,
        declared_value: [true, false],
        partial_receipt: false,
        postal_items_in_ops: [true, false]
      }
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

    # Returns validation rules for a given postal delivery type
    # @param type [String, Symbol] the type to get rules for
    # @return [Hash, nil] the validation rules if the type has them, nil otherwise
    def self.validation_rules(type)
      VALIDATION_RULES[type.to_sym]
    rescue NoMethodError
      nil
    end

    # Validates if the given parameters match the rules for the given type
    # @param type [String, Symbol] the postal delivery type
    # @param params [Hash] the parameters to validate
    # @return [Array<String>] array of error messages, empty if validation passes
    def self.validate_params(type, params)
      rules = validation_rules(type)
      return [] unless rules

      errors = []
      type_sym = type.to_sym

      # Check negotiated_rate
      if rules[:negotiated_rate] != params[:negotiated_rate]
        errors << "negotiated_rate must be #{rules[:negotiated_rate]} for #{type_sym}"
      end

      # Check declared_value
      if rules[:declared_value] && !rules[:declared_value].include?(params[:is_declared_value])
        errors << "is_declared_value must be one of #{rules[:declared_value]} for #{type_sym}"
      end

      # Check partial_receipt
      if rules[:partial_receipt] != params[:is_partial_receipt]
        errors << "is_partial_receipt must be #{rules[:partial_receipt]} for #{type_sym}"
      end

      # Check postal_items_in_ops
      if rules[:postal_items_in_ops]
        if rules[:postal_items_in_ops].is_a?(Array)
          unless rules[:postal_items_in_ops].include?(params[:postal_items_in_ops])
            errors << "postal_items_in_ops must be one of #{rules[:postal_items_in_ops]} for #{type_sym}"
          end
        elsif rules[:postal_items_in_ops] != params[:postal_items_in_ops]
          if rules[:postal_items_in_ops] == true
            errors << "postal_items_in_ops must be one of [true] for #{type_sym}"
          else
            errors << "postal_items_in_ops must be #{rules[:postal_items_in_ops]} for #{type_sym}"
          end
        end
      end

      errors
    end
  end
end