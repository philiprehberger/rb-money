# philiprehberger-money

[![Tests](https://github.com/philiprehberger/rb-money/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-money/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-money.svg)](https://rubygems.org/gems/philiprehberger-money)
[![License](https://img.shields.io/github/license/philiprehberger/rb-money)](LICENSE)

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
| `.from_amount(amount, currency_code)` | Create from decimal amount with banker's rounding |

### `Money` instance methods

| Method | Description |
|--------|-------------|
| `#cents` | Integer subunit amount |
| `#currency` | Currency object with code, symbol, and formatting rules |
| `#amount` | BigDecimal representation of the amount |
| `#to_f` | Float representation of the amount |
| `#+(other)` | Add two same-currency Money objects |
| `#-(other)` | Subtract two same-currency Money objects |
| `#*(numeric)` | Multiply by a number (banker's rounding) |
| `#/(numeric)` | Divide by a number (banker's rounding) |
| `#-@` | Negate the amount |
| `#abs` | Absolute value |
| `#allocate(ratios)` | Split by ratios using largest remainder method |
| `#format(symbol:, code:, thousands:)` | Format as string with options |
| `#to_s` | Format with default options |
| `#convert_to(target_code, rate:)` | Convert to another currency |
| `#zero?` | True if amount is zero |
| `#positive?` | True if amount is positive |
| `#negative?` | True if amount is negative |
| `#<=>(other)` | Compare same-currency amounts |
| `#eql?(other)` | Value equality check |
| `#hash` | Hash for use as hash key |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
