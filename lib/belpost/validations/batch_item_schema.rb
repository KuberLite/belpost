# frozen_string_literal: true

require "dry-validation"

module Belpost
  module Validation
    # Schema for validating batch item data
    class BatchItemSchema < Dry::Validation::Contract
      params do
        required(:items).array(:hash) do
          optional(:recipient_id).maybe(:integer)
          optional(:recipient_foreign_id).maybe(:string)
          optional(:recipient_object).maybe(:hash) do
            optional(:foreign_id).maybe(:string)
            required(:type).filled(:string, included_in?: %w[legal individual individual_entrepreneur])

            optional(:first_name).maybe(:string)
            optional(:last_name).maybe(:string)
            optional(:second_name).maybe(:string)

            optional(:company_name).maybe(:string)

            required(:address).hash do
              required(:address_type).filled(:string, included_in?: %w[address on_demand subscriber_box])
              required(:postcode).filled(:string)
              optional(:ops_id).maybe(:string)
              required(:country_code).filled(:string)
              optional(:region).maybe(:string)
              optional(:district).maybe(:string)
              required(:city).filled(:string)
              optional(:building).maybe(:string)
              optional(:housing).maybe(:string)
              optional(:apartment).maybe(:string)
              optional(:cell_number).maybe(:string)
            end

            optional(:phone).maybe(:string)
          end

          optional(:s10code).maybe(:string)
          optional(:notification_s10code).maybe(:string)
          required(:notification).filled(:integer, included_in?: [0, 1, 2, 5, 7])
          required(:category).filled(:integer, included_in?: [0, 1, 2])
          required(:weight).filled(:integer, gt?: 0)

          optional(:addons).maybe(:hash) do
            optional(:declared_value).maybe(:float, gt?: 0)
            optional(:cash_on_delivery).maybe(:float, gt?: 0)
            optional(:careful_fragile).maybe(:bool)
            optional(:hand_over_personally).maybe(:bool)
            optional(:subpoena).maybe(:bool)
            optional(:description).maybe(:bool)
            optional(:bulky).maybe(:bool)
            optional(:recipient_payment).maybe(:bool)
            optional(:documents_return).maybe(:bool)
            optional(:deliver_to_work).maybe(:bool)
            optional(:open_upon_delivery).maybe(:bool)
            optional(:time_of_delivery).maybe(:hash) do
              required(:type).filled(:string, included_in?: %w[level1 level2 level3 level4])
              optional(:time_interval).hash do
                required(:from).filled(:string)
                required(:to).filled(:string)
              end
            end
            optional(:free_return).maybe(:bool)
            optional(:partial_return).maybe(:bool)
            optional(:government).maybe(:bool)
            optional(:military).maybe(:bool)
            optional(:service).maybe(:bool)
            optional(:shelf_life).maybe(:integer, included_in?: (10..30))
            optional(:email).maybe(:string)
            optional(:phone).maybe(:string)
            optional(:coordinate_delivery_interval).maybe(:bool)
          end
        end
      end

      rule('items[].recipient_object.first_name') do
        if key? && value.is_a?(Array)
          value.each_with_index do |item, idx|
            if item[:recipient_object] && item[:recipient_object][:type] == 'individual' && item[:recipient_object][:first_name].nil?
              key(:"items.#{idx}.recipient_object.first_name").failure('must be filled for individual type')
            end
          end
        end
      end

      rule('items[].recipient_object.last_name') do
        if key? && value.is_a?(Array)
          value.each_with_index do |item, idx|
            if item[:recipient_object] && item[:recipient_object][:type] == 'individual' && item[:recipient_object][:last_name].nil?
              key(:"items.#{idx}.recipient_object.last_name").failure('must be filled for individual type')
            end
          end
        end
      end

      rule('items[].recipient_object.company_name') do
        if key? && value.is_a?(Array)
          value.each_with_index do |item, idx|
            if item[:recipient_object] &&
               (item[:recipient_object][:type] == 'legal' || item[:recipient_object][:type] == 'individual_entrepreneur') &&
               item[:recipient_object][:company_name].nil?
              key(:"items.#{idx}.recipient_object.company_name").failure('must be filled for legal or individual_entrepreneur type')
            end
          end
        end
      end

      rule('items[].recipient_object.address.ops_id') do
        if key? && value.is_a?(Array)
          value.each_with_index do |item, idx|
            if item[:recipient_object] &&
               item[:recipient_object][:address] &&
               item[:recipient_object][:address][:address_type] == 'address' &&
               item[:recipient_object][:address][:ops_id].nil?
              key(:"items.#{idx}.recipient_object.address.ops_id").failure('must be filled for address type')
            end
          end
        end
      end

      rule('items[].recipient_object.address.cell_number') do
        if key? && value.is_a?(Array)
          value.each_with_index do |item, idx|
            if item[:recipient_object] &&
               item[:recipient_object][:address] &&
               item[:recipient_object][:address][:address_type] == 'subscriber_box' &&
               item[:recipient_object][:address][:cell_number].nil?
              key(:"items.#{idx}.recipient_object.address.cell_number").failure('must be filled for subscriber_box type')
            end
          end
        end
      end

      rule('items[].recipient_object') do
        if key? && value.is_a?(Array)
          value.each_with_index do |item, idx|
            if item[:recipient_id].nil? && item[:recipient_foreign_id].nil? && item[:recipient_object].nil?
              key(:"items.#{idx}.recipient_object").failure('must be provided if recipient_id and recipient_foreign_id are null')
            end
          end
        end
      end

      # Add validation to ensure e-commerce has the proper notifications
      rule('items[].notification') do
        if key? && value.is_a?(Array)
          value.each_with_index do |item, idx|
            if item[:notification] == 5 && (!item[:addons] || !item[:addons][:email])
              key(:"items.#{idx}.addons.email").failure('email is required for electronic notification (5)')
            end
          end
        end
      end

      # Add class method to make it callable directly
      def self.call(params)
        new.call(params)
      end
    end
  end
end