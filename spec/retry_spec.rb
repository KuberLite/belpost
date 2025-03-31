# frozen_string_literal: true

RSpec.describe Belpost::Retry do
  describe ".with_retry" do
    context "when operation succeeds on first attempt" do
      it "executes the block once and returns the result" do
        counter = 0
        
        result = described_class.with_retry do
          counter += 1
          "success"
        end

        expect(result).to eq("success")
        expect(counter).to eq(1)
      end
    end

    context "when operation fails with retryable error" do
      let(:max_retries) { 2 }
      let(:initial_delay) { 0.01 } # small delay for tests

      it "retries the operation" do
        counter = 0
        
        result = described_class.with_retry(max_retries: max_retries, initial_delay: initial_delay) do
          counter += 1
          if counter < 3
            raise Belpost::NetworkError, "Network error"
          else
            "success"
          end
        end

        expect(result).to eq("success")
        expect(counter).to eq(3)
      end

      it "retries the operation with increasing delays" do
        counter = 0
        start_time = Time.now
        
        result = described_class.with_retry(max_retries: max_retries, initial_delay: 0.05) do
          counter += 1
          if counter < 3
            raise Belpost::TimeoutError, "Timeout"
          else
            "success"
          end
        end
        
        elapsed_time = Time.now - start_time

        expect(result).to eq("success")
        expect(counter).to eq(3)
        # At least initial_delay + (initial_delay * 2) for the two retries
        expect(elapsed_time).to be >= 0.15
      end

      it "raises the last error when max retries exceeded" do
        counter = 0
        
        expect do
          described_class.with_retry(max_retries: max_retries, initial_delay: initial_delay) do
            counter += 1
            raise Belpost::ServerError, "Server error"
          end
        end.to raise_error(Belpost::ServerError, "Server error")
        
        expect(counter).to eq(max_retries + 1)
      end
    end

    context "when operation fails with non-retryable error" do
      it "does not retry for ValidationError" do
        counter = 0
        
        expect do
          described_class.with_retry do
            counter += 1
            raise Belpost::ValidationError, "Validation error"
          end
        end.to raise_error(Belpost::ValidationError, "Validation error")
        
        expect(counter).to eq(1)
      end

      it "does not retry for standard errors" do
        counter = 0
        
        expect do
          described_class.with_retry do
            counter += 1
            raise StandardError, "Standard error"
          end
        end.to raise_error(StandardError, "Standard error")
        
        expect(counter).to eq(1)
      end
    end

    context "with custom retry parameters" do
      it "uses provided max_retries value" do
        counter = 0
        
        result = described_class.with_retry(max_retries: 5, initial_delay: 0.01) do
          counter += 1
          if counter < 6
            raise Belpost::NetworkError, "Network error"
          else
            "success"
          end
        end

        expect(result).to eq("success")
        expect(counter).to eq(6)
      end
    end
  end
end 