# philiprehberger-money

[![Tests](https://github.com/philiprehberger/rb-money/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-money/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-money.svg)](https://rubygems.org/gems/philiprehberger-money)
[![GitHub release](https://img.shields.io/github/v/release/philiprehberger/rb-money)](https://github.com/philiprehberger/rb-money/releases)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-money)](https://github.com/philiprehberger/rb-money/commits/main)
[![License](https://img.shields.io/github/license/philiprehberger/rb-money)](LICENSE)
[![Bug Reports](https://img.shields.io/github/issues/philiprehberger/rb-money/bug)](https://github.com/philiprehberger/rb-money/issues?q=is%3Aissue+is%3Aopen+label%3Abug)
[![Feature Requests](https://img.shields.io/github/issues/philiprehberger/rb-money/enhancement)](https://github.com/philiprehberger/rb-money/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ec6cb9)](https://github.com/sponsors/philiprehberger)

Immutable money value object with integer subunit storage and multi-currency formatting

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-money"
```

Or install directly:

```bash
gem install philiprehberger-money
```

## Usage

```ruby
require "philiprehberger/money"

price = Philiprehberger::Money.new(1999, :usd)
price.amount  # => 19.99
price.to_s    # => "$19.99"
```

### Arithmetic

```ruby
require "philiprehberger/money"

a = Philiprehberger::Money.new(1000, :usd)
b = Philiprehberger::Money.new(500, :usd)

sum  = a + b       # => $15.00
diff = a - b       # => $5.00
mult = a * 2       # => $20.00
quot = a / 3       # => $3.33 (banker's rounding)
neg  = -a          # => -$10.00
abs  = neg.abs     # => $10.00
```

### Formatting

```ruby
require "philiprehberger/money"

usd = Philiprehberger::Money.new(1999, :usd)
usd.format                          # => "$19.99"
usd.format(code: true)              # => "$19.99 USD"
usd.format(symbol: false)           # => "19.99"

eur = Philiprehberger::Money.new(1999, :eur)
eur.format                          # => "€19,99"

jpy = Philiprehberger::Money.new(2000, :jpy)
jpy.format                          # => "¥2,000"
```

### Parsing

```ruby
require "philiprehberger/money"

Philiprehberger::Money.parse("$1,234.56")       # => Money(123456, :usd)
Philiprehberger::Money.parse("1.234,56 EUR")     # => Money(123456, :eur)
Philiprehberger::Money.parse("¥2000", currency: :jpy)  # => Money(2000, :jpy)
Philiprehberger::Money.parse("-$19.99")          # => Money(-1999, :usd)
```

### Percentage Operations

```ruby
require "philiprehberger/money"

price = Philiprehberger::Money.new(10000, :usd)  # $100.00

price.percent(15)            # => $15.00 (15% tip)
price.add_percent(20)        # => $120.00 (with 20% tax)
price.subtract_percent(25)   # => $75.00 (25% discount)
```

### Allocation

```ruby
require "philiprehberger/money"

total = Philiprehberger::Money.new(1000, :usd)
shares = total.allocate([0.5, 0.3, 0.2])
shares.map(&:cents)  # => [500, 300, 200]

# Remainder cents are distributed fairly
odd = Philiprehberger::Money.new(100, :usd)
parts = odd.allocate([1, 1, 1])
parts.map(&:cents)   # => [34, 33, 33]
parts.sum(&:cents)   # => 100
```

### Split

```ruby
require "philiprehberger/money"

total = Philiprehberger::Money.new(1000, :usd)
parts = total.split(3)
parts.map(&:cents)   # => [334, 333, 333]
parts.sum(&:cents)   # => 1000
```

### Rounding Modes

```ruby
require "philiprehberger/money"

# Default: banker's rounding (half to even)
Philiprehberger::Money.from_amount(0.025, :usd)                        # => 2 cents

# Standard rounding (half up)
Philiprehberger::Money.from_amount(0.025, :usd, rounding: :half_up)    # => 3 cents

# Always round up
Philiprehberger::Money.from_amount(0.021, :usd, rounding: :ceil)       # => 3 cents

# Always round down
Philiprehberger::Money.from_amount(0.029, :usd, rounding: :floor)      # => 2 cents
```

### Custom Currencies

```ruby
require "philiprehberger/money"

Philiprehberger::Money::Currency.register(
  code: "XAU",
  name: "Gold Troy Ounce",
  symbol: "Au",
  subunit_to_unit: 100,
  symbol_first: true
)

gold = Philiprehberger::Money.from_amount(1950.50, :xau)
gold.format  # => "Au1,950.50"
```

### Currency Conversion

```ruby
require "philiprehberger/money"

usd = Philiprehberger::Money.new(1000, :usd)
eur = usd.convert_to(:eur, rate: 0.85)
eur.cents           # => 850
eur.currency.code   # => :eur
```

### Comparison

```ruby
require "philiprehberger/money"

a = Philiprehberger::Money.new(1000, :usd)
b = Philiprehberger::Money.new(2000, :usd)

a < b   # => true
a == b  # => false
a.zero? # => false
```

## API

### `Money` class methods

| Method | Description |
|--------|-------------|
| `.new(cents, currency_code)` | Create from integer subunits and currency code |
| `.from_amount(amount, currency_code, rounding:)` | Create from decimal amount with configurable rounding |
| `.parse(string, currency:)` | Parse a formatted money string into a Money object |

### `Money` instance methods

| Method | Description |
|--------|-------------|
| `#cents` | Integer subunit amount |
| `#currency` | Currency object with code, symbol, and formatting rules |
| `#amount` | BigDecimal representation of the amount |
| `#to_f` | Float representation of the amount |
| `#rounding_mode` | The rounding mode used for arithmetic |
| `#+(other)` | Add two same-currency Money objects |
| `#-(other)` | Subtract two same-currency Money objects |
| `#*(numeric)` | Multiply by a number (uses stored rounding mode) |
| `#/(numeric)` | Divide by a number (uses stored rounding mode) |
| `#-@` | Negate the amount |
| `#abs` | Absolute value |
| `#percent(n)` | Return n% of the amount |
| `#add_percent(n)` | Return money + n% |
| `#subtract_percent(n)` | Return money - n% |
| `#allocate(ratios)` | Split by ratios using largest remainder method |
| `#split(n)` | Split equally among n parts |
| `#format(symbol:, code:, thousands:)` | Format as string with options |
| `#to_s` | Format with default options |
| `#convert_to(target_code, rate:)` | Convert to another currency |
| `#zero?` | True if amount is zero |
| `#positive?` | True if amount is positive |
| `#negative?` | True if amount is negative |
| `#<=>(other)` | Compare same-currency amounts |
| `#eql?(other)` | Value equality check |
| `#hash` | Hash for use as hash key |

### `Currency` class methods

| Method | Description |
|--------|-------------|
| `.find(code)` | Look up a currency by code |
| `.register(code:, name:, symbol:, ...)` | Register a custom currency |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this package useful, consider giving it a star on GitHub — it helps motivate continued maintenance and development.

[![LinkedIn](https://img.shields.io/badge/Philip%20Rehberger-LinkedIn-0A66C2?logo=linkedin)](https://www.linkedin.com/in/philiprehberger)
[![More packages](https://img.shields.io/badge/more-open%20source%20packages-blue)](https://philiprehberger.com/open-source-packages)

## License

[MIT](LICENSE)
