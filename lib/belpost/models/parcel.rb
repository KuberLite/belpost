# frozen_string_literal: true

module Belpost
  module Models
    class Parcel
      attr_reader :data

      def initialize(data)
        @data = data
      end

      def to_h
        data
      end

      def to_json(*_args)
        data.to_json
      end
    end
  end
end
