# Belpost

Client for working with Belpochta API (Belpochta).

## Установка

Add this line to your application's Gemfile:

```ruby
gem 'belpost'
```

And do:

```bash
$ bundle install
```

Or install it yourself:

```bash
$ gem install belpost
```

## Настройка

Configure the client to work with the Belpochta API:

```ruby
require 'belpost'

Belpost.configure do |config|
  config.jwt_token = 'your_jwt_token_from_Belpochta'
  config.base_url = 'https://api.belpost.by'
  config.timeout = 30 # Timeout in seconds (default 10)
end
```

You can also use environment variables:

```
BELPOST_JWT_TOKEN=your_jwt_token_from_Belpochta
BELPOST_BASE_URL=https://api.belpost.by
BELPOST_TIMEOUT=30
```

## Usage

### Parcel creation

#### Base example

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
      organization_name: "ООО \"Компания\"",
      taxpayer_number: "123456789",
      IBAN: "BY26BAPB30123418400100000000",
      BIC: "BAPBBY2X",
      bank: "ОАО 'БЕЛАГРОПРОМБАНК'"
    },
    location: {
      code: "225212",
      region: "Брестская",
      district: "Березовский",
      locality: {
        type: "город",
        name: "Береза"
      },
      road: {
        type: "улица",
        name: "Ленина"
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
      first_name: "Иван",
      second_name: "Иванович",
      last_name: "Иванов"
    },
    location: {
      code: "231365",
      region: "Гродненская",
      district: "Ивьевский",
      locality: {
        type: "деревня",
        name: "Дуды"
      },
      road: {
        type: "улица",
        name: "Центральная"
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
puts "Трекинг код: #{response["data"]["parcel"]["s10code"]}"
```

#### Usage ParcelBuilder

```ruby
client = Belpost::Client.new

# Создание внутренней посылки
parcel_data = Belpost::Models::ParcelBuilder.new
  .with_type("package")
  .with_attachment_type("products")
  .with_weight(1500) # вес в граммах
  .with_dimensions(300, 200, 100) # длина, ширина, высота в мм
  .to_country("BY")
  .with_declared_value(100)
  .with_cash_on_delivery(50)
  .add_service(:simple_notification)
  .add_service(:email_notification)
  .from_legal_person("ООО \"Компания\"")
  .with_sender_details(
    taxpayer_number: "123456789",
    bank: "ОАО 'БЕЛАГРОПРОМБАНК'",
    iban: "BY26BAPB30123418400100000000",
    bic: "BAPBBY2X"
  )
  .with_sender_location(
    postal_code: "225212",
    region: "Брестская",
    district: "Березовский",
    locality_type: "город",
    locality_name: "Береза",
    road_type: "улица",
    road_name: "Ленина",
    building: "1"
  )
  .with_sender_contact(
    email: "test@example.com",
    phone: "375291234567"
  )
  .to_natural_person(
    first_name: "Иван",
    last_name: "Иванов", 
    second_name: "Иванович"
  )
  .with_recipient_location(
    postal_code: "231365",
    region: "Гродненская",
    district: "Ивьевский",
    locality_type: "деревня",
    locality_name: "Дуды",
    road_type: "улица",
    road_name: "Центральная",
    building: "1"
  )
  .with_recipient_contact(
    phone: "375291234567"
  )
  .build

response = client.create_parcel(parcel_data)
puts "Трекинг код: #{response["data"]["parcel"]["s10code"]}"
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
    name: "Книга",
    local: "Книга",
    unit: {
      local: "ШТ",
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
  .to_country("DE") # Германия
  .with_declared_value(50, "USD")
  .from_legal_person("ООО \"Компания\"")
  .with_sender_location(
    postal_code: "225212",
    region: "Брестская",
    district: "Березовский",
    locality_type: "город",
    locality_name: "Береза",
    road_type: "улица",
    road_name: "Ленина",
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
puts "Трекинг код: #{response["data"]["parcel"]["s10code"]}"
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
- `Belpost::TimeoutError` - request timeout

Example of error handling:

```ruby
begin
  client = Belpost::Client.new
  response = client.create_parcel(parcel_data)
rescue Belpost::ValidationError => e
  puts "Ошибка валидации: #{e.message}"
rescue Belpost::AuthenticationError => e
  puts "Ошибка аутентификации: #{e.message}"
rescue Belpost::ApiError => e
  puts "Ошибка API: #{e.message}"
end
```
## Documentation

Full documentation on the Belpochta API is available in the official documentation.

## Development

After cloning the repository, run `bin/setup` to install dependencies. Then run `rake spec` to run tests.

## Contributing

Bug reports and pull requests are welcome on GitHub.
