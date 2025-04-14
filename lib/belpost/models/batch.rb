# frozen_string_literal: true

module Belpost
  module Models
    # Model class for batch mailing
    class Batch
      attr_reader :postal_delivery_type, :direction, :payment_type, :negotiated_rate,
                  :name, :card_number, :postal_items_in_ops, :category, :is_document,
                  :is_declared_value, :is_partial_receipt

      def initialize(data)
        @postal_delivery_type = data[:postal_delivery_type]
        @direction = data[:direction]
        @payment_type = data[:payment_type]
        @negotiated_rate = data[:negotiated_rate]
        @name = data[:name]
        @card_number = data[:card_number]
        @postal_items_in_ops = data[:postal_items_in_ops]
        @category = data[:category]
        @is_document = data[:is_document]
        @is_declared_value = data[:is_declared_value]
        @is_partial_receipt = data[:is_partial_receipt]
      end

      def to_h
        {
          postal_delivery_type: @postal_delivery_type,
          direction: @direction,
          payment_type: @payment_type,
          negotiated_rate: @negotiated_rate,
          name: @name,
          card_number: @card_number,
          postal_items_in_ops: @postal_items_in_ops,
          category: @category,
          is_document: @is_document,
          is_declared_value: @is_declared_value,
          is_partial_receipt: @is_partial_receipt
        }.compact
      end
    end
  end
end 