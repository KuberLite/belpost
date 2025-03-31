# frozen_string_literal: true

module Belpost
  class Retry
    MAX_RETRIES = 3
    INITIAL_DELAY = 1

    def self.with_retry(max_retries: MAX_RETRIES, initial_delay: INITIAL_DELAY)
      retries = 0
      delay = initial_delay

      begin
        yield
      rescue NetworkError, TimeoutError, ServerError => e
        retries += 1
        if retries <= max_retries
          sleep(delay)
          delay *= 2
          retry
        else
          raise e
        end
      end
    end
  end
end 