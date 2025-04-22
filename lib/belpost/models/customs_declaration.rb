# frozen_string_literal: true

module Belpost
  module Models
    class CustomsDeclaration
      VALID_CATEGORIES = %w[gift documents sample returned_goods merchandise other].freeze

      attr_reader :items, :price, :category, :explanation, :comments, :invoice, :licences, :certificates

      def initialize(data = {})
        @items = data[:items] || []
        @price = data[:price] || {}
        @category = data[:category]
        @explanation = data[:explanation]
        @comments = data[:comments]
        @invoice = data[:invoice]
        @licences = data[:licences] || []
        @certificates = data[:certificates] || []
      end

      def add_item(item_data)
        @items << item_data
      end

      def set_price(currency, value)
        @price = { currency: currency, value: value }
      end

      def set_category(category)
        unless VALID_CATEGORIES.include?(category)
          raise ValidationError, "Invalid category. Must be one of: #{VALID_CATEGORIES.join(', ')}"
        end

        @category = category
      end

      def to_h
        {
          items: @items,
          price: @price,
          category: @category,
          explanation: @explanation,
          comments: @comments,
          invoice: @invoice,
          licences: @licences,
          certificates: @certificates
        }.compact
      end

      def valid?
        return false if @category && !VALID_CATEGORIES.include?(@category)
        return false if @category == "other" && @explanation.nil?

        if %w[merchandise sample returned_goods].include?(@category)
          return false if @items.empty?
          return false if @price.empty?
        end

        true
      end
    end
  end
end
