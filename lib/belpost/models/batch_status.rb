# frozen_string_literal: true

module Belpost
  module Models
    # Helper class for batch status translations and utilities
    class BatchStatus
      # Mapping of status codes to their Russian translations
      TRANSLATIONS = {
        "uncommitted" => "В обработке",
        "committed" => "Сформирована"
      }.freeze

      # Get the Russian translation for a status
      #
      # @param status [String] The status code ('uncommitted' or 'committed')
      # @return [String] The Russian translation or the original status if not found
      def self.translate(status)
        TRANSLATIONS[status] || status
      end

      # Get all possible statuses
      #
      # @return [Array<String>] Array of all possible status values
      def self.all
        %w[uncommitted committed]
      end

      # Check if a status is valid
      #
      # @param status [String] The status to check
      # @return [Boolean] True if valid, false otherwise
      def self.valid?(status)
        all.include?(status)
      end
    end
  end
end 