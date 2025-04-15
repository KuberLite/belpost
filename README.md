# Belpost

Client for working with Belpochta API (Belpost).

![Tests](https://github.com/KuberLite/belpost/actions/workflows/test.yml/badge.svg)
![Gem Version](https://badge.fury.io/rb/belpost.svg)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'belpost'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself:

```bash
$ gem install belpost
```

## Configuration

Configure the client to work with the Belpost API:

```ruby
require 'belpost'

Belpost.configure do |config|
  config.jwt_token = 'your_jwt_token_from_belpost'
  config.base_url = 'https://api.belpost.by'
  config.timeout = 30 # Timeout in seconds (default 10)
end
```

You can also use environment variables:

```
BELPOST_JWT_TOKEN=your_jwt_token_from_belpost
BELPOST_BASE_URL=https://api.belpost.by
BELPOST_TIMEOUT=30
```

## Usage

### Creating a parcel

#### Basic example

```ruby
client = Belpost::Client.new

parcel_data = {
  parcel: {
    type: "package",
    attachment_type: "products",
    measures: {
      weight: 12
    },
    departure: {
      country: "BY",
      place: "post_office"
    },
    arrival: {
      country: "BY",
      place: "post_office"
    }
  },
  addons: {
    declared_value: {
      currency: "BYN",
      value: 100
    },
    cash_on_delivery: {
      currency: "BYN",
      value: 10
    }
  },
  sender: {
    type: "legal_person",
    info: {
      organization_name: "LLC \"Company\"",
      taxpayer_number: "123456789",
      IBAN: "BY26BAPB30123418400100000000",
      BIC: "BAPBBY2X",
      bank: "JSC 'BELAGROPROMBANK'"
    },
    location: {
      code: "225212",
      region: "Brest",
      district: "Bereza",
      locality: {
        type: "city",
        name: "Bereza"
      },
      road: {
        type: "street",
        name: "Lenin"
      },
      building: "1",
      housing: "",
      apartment: ""
    },
    email: "test@example.com",
    phone: "375291234567"
  },
  recipient: {
    type: "natural_person",
    info: {
      first_name: "Ivan",
      second_name: "Ivanovich",
      last_name: "Ivanov"
    },
    location: {
      code: "231365",
      region: "Grodno",
      district: "Ivye",
      locality: {
        type: "village",
        name: "Dudy"
      },
      road: {
        type: "street",
        name: "Central"
      },
      building: "1",
      housing: "",
      apartment: ""
    },
    email: "",
    phone: "375291234567"
  }
}

response = client.create_parcel(parcel_data)
puts "Tracking code: #{response["data"]["parcel"]["s10code"]}"
```

#### Using ParcelBuilder

```ruby
client = Belpost::Client.new

# Creating a domestic parcel
parcel_data = Belpost::Models::ParcelBuilder.new
  .with_type("package")
  .with_attachment_type("products")
  .with_weight(1500) # weight in grams
  .with_dimensions(300, 200, 100) # length, width, height in mm
  .to_country("BY")
  .with_declared_value(100)
  .with_cash_on_delivery(50)
  .add_service(:simple_notification)
  .add_service(:email_notification)
  .from_legal_person("LLC \"Company\"")
  .with_sender_details(
    taxpayer_number: "123456789",
    bank: "JSC 'BELAGROPROMBANK'",
    iban: "BY26BAPB30123418400100000000",
    bic: "BAPBBY2X"
  )
  .with_sender_location(
    postal_code: "225212",
    region: "Brest",
    district: "Bereza",
    locality_type: "city",
    locality_name: "Bereza",
    road_type: "street",
    road_name: "Lenin",
    building: "1"
  )
  .with_sender_contact(
    email: "test@example.com",
    phone: "375291234567"
  )
  .to_natural_person(
    first_name: "Ivan",
    last_name: "Ivanov", 
    second_name: "Ivanovich"
  )
  .with_recipient_location(
    postal_code: "231365",
    region: "Grodno",
    district: "Ivye",
    locality_type: "village",
    locality_name: "Dudy",
    road_type: "street",
    road_name: "Central",
    building: "1"
  )
  .with_recipient_contact(
    phone: "375291234567"
  )
  .build

response = client.create_parcel(parcel_data)
puts "Tracking code: #{response["data"]["parcel"]["s10code"]}"
```

#### Creating an international parcel with a customs declaration

```ruby
client = Belpost::Client.new

# Creating a customs declaration
customs_declaration = Belpost::Models::CustomsDeclaration.new
customs_declaration.set_category("gift")
customs_declaration.set_price("USD", 50)
customs_declaration.add_item(
  {
    name: "Book",
    local: "Book",
    unit: {
      local: "PCS",
      en: "PCS"
    },
    count: 1,
    weight: 500,
    price: {
      currency: "USD",
      value: 50
    },
    country: "BY"
  }
)

# Creating an international parcel
parcel_data = Belpost::Models::ParcelBuilder.new
  .with_type("package")
  .with_attachment_type("products")
  .with_weight(500)
  .to_country("DE") # Germany
  .with_declared_value(50, "USD")
  .from_legal_person("LLC \"Company\"")
  .with_sender_location(
    postal_code: "225212",
    region: "Brest",
    district: "Bereza",
    locality_type: "city",
    locality_name: "Bereza",
    road_type: "street",
    road_name: "Lenin",
    building: "1"
  )
  .with_sender_contact(
    email: "test@example.com",
    phone: "375291234567"
  )
  .to_natural_person(
    first_name: "John",
    last_name: "Doe"
  )
  .with_foreign_recipient_location(
    postal_code: "10115",
    locality: "Berlin",
    address: "Unter den Linden 77"
  )
  .with_recipient_contact(
    phone: "4901234567890"
  )
  .with_customs_declaration(customs_declaration)
  .build

response = client.create_parcel(parcel_data)
puts "Tracking code: #{response["data"]["parcel"]["s10code"]}"
```

### Getting a list of available countries

```ruby
client = Belpost::Client.new
countries = client.fetch_available_countries
puts countries
```

### Obtaining data for postal item validation

```ruby
client = Belpost::Client.new
validation_data = client.validate_postal_delivery("BY")
puts validation_data
```

### Obtaining HS codes for customs declaration

```ruby
client = Belpost::Client.new
hs_codes = client.fetch_hs_codes
puts hs_codes
```

### Searching for postal codes

```ruby
client = Belpost::Client.new
postcodes = client.search_postcode(
  city: "Витебск",
  street: "Ильинского",
  building: "51/1",  # optional
  limit: 50          # optional, default: 50, range: 1-200
)
puts postcodes
```

### Finding a batch by ID

```ruby
client = Belpost::Client.new
batch = client.find_batch_by_id(123)
puts batch
```

## Error handling

The client may throw the following exceptions:

- `Belpost::ConfigurationError` - configuration error
- `Belpost::ValidationError` - data validation error
- `Belpost::ApiError` - basic API error
- `Belpost::AuthenticationError` - authentication error
- `Belpost::InvalidRequestError` - request error
- `Belpost::RateLimitError` - request limit exceeded
- `Belpost::ServerError` - server error
- `Belpost::NetworkError` - network error
- `Belpost::RequestError` - request timeout

Example of error handling:

```ruby
begin
  client = Belpost::Client.new
  response = client.create_parcel(parcel_data)
rescue Belpost::ValidationError => e
  puts "Validation error: #{e.message}"
rescue Belpost::AuthenticationError => e
  puts "Authentication error: #{e.message}"
rescue Belpost::ApiError => e
  puts "API error: #{e.message}"
end
```

## Documentation

Full documentation on the Belpost API is available in the official documentation.

## Development

After cloning the repository, run `bin/setup` to install dependencies. Then run `rake spec` to run tests. You can also run `bin/console` for an interactive REPL that allows you to experiment.

### Setting up test environment

For running tests, the gem uses environment variables that can be configured in different ways:

1. Copy the `.env.test.example` file to `.env.test` and adjust the values:
   ```
   cp .env.test.example .env.test
   ```

2. The test suite will automatically use these values, or fall back to default test values if not provided.

3. For CI environments, the necessary environment variables are already configured in the GitHub workflow files.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Continuous Integration (CI/CD)

The project is set up to use GitHub Actions for continuous integration (CI) and continuous delivery (CD):

1. **Testing**: Every push and pull request to the `master` branch automatically runs tests on various Ruby versions.
2. **Release**: When a tag starting with `v` is created (e.g., `v0.1.0`), the gem will be automatically published to RubyGems.

For more detailed information about the release process, see the [RELEASING.md](RELEASING.md) file.

## Contributing

For information on how to contribute to the project, please see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
