# Belpost

Клиент для работы с Belpochta API (Белпочта).

## Установка

Добавьте эту строку в Gemfile вашего приложения:

```ruby
gem 'belpost'
```

И выполните:

```bash
$ bundle install
```

Или установите самостоятельно:

```bash
$ gem install belpost
```

## Настройка

Настройте клиент для работы с API Белпочты:

```ruby
require 'belpost'

Belpost.configure do |config|
  config.jwt_token = 'ваш_jwt_токен_от_Белпочты'
  config.base_url = 'https://api.belpost.by'
  config.timeout = 30 # Таймаут в секундах (по умолчанию 10)
end
```

Вы также можете использовать переменные окружения:

```
BELPOST_JWT_TOKEN=ваш_jwt_токен_от_Белпочты
BELPOST_BASE_URL=https://api.belpost.by
BELPOST_TIMEOUT=30
```

## Использование

### Создание посылки

#### Базовый пример

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

#### Использование ParcelBuilder

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

#### Создание международной посылки с таможенной декларацией

```ruby
client = Belpost::Client.new

# Создание таможенной декларации
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

# Создание международной посылки
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

### Получение списка доступных стран

```ruby
client = Belpost::Client.new
countries = client.fetch_available_countries
puts countries
```

### Получение данных для валидации почтового отправления

```ruby
client = Belpost::Client.new
validation_data = client.validate_postal_delivery("BY")
puts validation_data
```

### Получение кодов HS для таможенного декларирования

```ruby
client = Belpost::Client.new
hs_codes = client.fetch_hs_codes
puts hs_codes
```

## Обработка ошибок

Клиент может выбрасывать следующие исключения:

- `Belpost::ConfigurationError` - ошибка конфигурации
- `Belpost::ValidationError` - ошибка валидации данных
- `Belpost::ApiError` - базовая ошибка API
- `Belpost::AuthenticationError` - ошибка аутентификации
- `Belpost::InvalidRequestError` - ошибка запроса
- `Belpost::RateLimitError` - превышен лимит запросов
- `Belpost::ServerError` - ошибка сервера
- `Belpost::NetworkError` - сетевая ошибка
- `Belpost::TimeoutError` - таймаут запроса

Пример обработки ошибок:

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

## Документация

Полная документация по API Белпочты доступна в официальной документации.

## Разработка

После клонирования репозитория выполните `bin/setup` для установки зависимостей. Затем выполните `rake spec` для запуска тестов.

## Contributing

Bug reports and pull requests are welcome on GitHub.
