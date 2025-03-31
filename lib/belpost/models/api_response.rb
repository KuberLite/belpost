# frozen_string_literal: true

module Belpost
  module Models
    class ApiResponse
      attr_reader :data, :status_code, :headers

      def initialize(data:, status_code:, headers:)
        @data = data
        @status_code = status_code
        @headers = headers
      end

      def success?
        status_code == 200
      end

      def to_h
        data
      end
    end
  end
end 