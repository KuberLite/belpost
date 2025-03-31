# frozen_string_literal: true

RSpec.describe Belpost::Models::CustomsDeclaration do
  describe "#initialize" do
    it "creates an empty customs declaration" do
      declaration = described_class.new
      expect(declaration.items).to eq([])
      expect(declaration.price).to eq({})
      expect(declaration.category).to be_nil
    end

    it "creates a customs declaration with provided data" do
      data = {
        items: [{ name: "Book", local: "Книга" }],
        price: { currency: "USD", value: 50 },
        category: "gift"
      }
      declaration = described_class.new(data)
      expect(declaration.items).to eq(data[:items])
      expect(declaration.price).to eq(data[:price])
      expect(declaration.category).to eq(data[:category])
    end
  end

  describe "#add_item" do
    it "adds an item to the declaration" do
      declaration = described_class.new
      item = { name: "Book", local: "Книга" }
      declaration.add_item(item)
      expect(declaration.items).to include(item)
    end
  end

  describe "#set_price" do
    it "sets the price with currency and value" do
      declaration = described_class.new
      declaration.set_price("USD", 50)
      expect(declaration.price).to eq({ currency: "USD", value: 50 })
    end
  end

  describe "#set_category" do
    it "sets a valid category" do
      declaration = described_class.new
      described_class::VALID_CATEGORIES.each do |category|
        declaration.set_category(category)
        expect(declaration.category).to eq(category)
      end
    end

    it "raises an error for invalid category" do
      declaration = described_class.new
      expect { declaration.set_category("invalid") }.to raise_error(Belpost::ValidationError)
    end
  end

  describe "#to_h" do
    it "returns a hash representation of the declaration" do
      declaration = described_class.new
      declaration.set_category("gift")
      declaration.set_price("USD", 50)
      declaration.add_item({ name: "Book", local: "Книга" })
      
      expect(declaration.to_h).to include(
        category: "gift",
        price: { currency: "USD", value: 50 },
        items: [{ name: "Book", local: "Книга" }]
      )
    end

    it "excludes nil values" do
      declaration = described_class.new
      declaration.set_category("gift")
      
      hash = declaration.to_h
      expect(hash).to include(category: "gift")
      expect(hash).not_to include(:explanation)
    end
  end

  describe "#valid?" do
    it "returns true for a valid gift declaration" do
      declaration = described_class.new
      declaration.set_category("gift")
      expect(declaration.valid?).to be true
    end

    it "returns false when 'other' category without explanation" do
      declaration = described_class.new
      declaration.set_category("other")
      expect(declaration.valid?).to be false
    end

    it "returns true when 'other' category with explanation" do
      declaration = described_class.new({ 
        category: "other", 
        explanation: "Special item" 
      })
      expect(declaration.valid?).to be true
    end

    it "returns false for a commercial declaration without items" do
      declaration = described_class.new
      declaration.set_category("merchandise")
      expect(declaration.valid?).to be false
    end

    it "returns false for a commercial declaration without price" do
      declaration = described_class.new
      declaration.set_category("merchandise")
      declaration.add_item({ name: "Product", local: "Продукт" })
      expect(declaration.valid?).to be false
    end

    it "returns true for a valid commercial declaration" do
      declaration = described_class.new
      declaration.set_category("merchandise")
      declaration.set_price("USD", 100)
      declaration.add_item({ name: "Product", local: "Продукт" })
      expect(declaration.valid?).to be true
    end
  end
end 