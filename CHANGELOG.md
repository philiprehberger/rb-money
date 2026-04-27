# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0] - 2026-04-26

### Added
- `Money#round(precision = nil)` — return a new `Money` rounded to the given decimal precision (defaults to currency exponent)
- `Currency#exponent` — public accessor for currency decimal precision

## [0.5.0] - 2026-04-15

### Added
- `Money#tax_breakdown(rate)` returns a hash with net, tax, and gross Money objects
- `Money#clamp(min, max)` constrains a money value within same-currency bounds

## [0.4.0] - 2026-04-10

### Added
- `Money#to_h` for hash serialization (cents, amount, currency, formatted)
- `Money#deconstruct_keys` for Ruby 3.x `case/in` pattern matching

## [0.3.1] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.3.0] - 2026-03-31

### Added
- `Money::ExchangeRate` store for managing conversion rates
- `#exchange_to(currency)` for automatic rate lookup conversion
- `Money.sum(moneys, target_currency:)` for aggregating mixed-currency amounts
- `#round_to_nearest(increment)` for rounding to nearest N subunits

## [0.2.0] - 2026-03-28

### Added
- `Money.parse(string, currency:)` for parsing formatted money strings back into Money objects
- `#percent(n)`, `#add_percent(n)`, `#subtract_percent(n)` for percentage operations
- `Currency.register(code:, name:, ...)` for registering custom currencies
- `rounding:` option on `Money.from_amount` supporting `:half_even`, `:half_up`, `:ceil`, `:floor`
- `#split(n)` convenience method for equal allocation

## [0.1.0] - 2026-03-21

### Added

- Immutable `Money` value object with integer subunit (cents) storage
- `Money.new(cents, currency)` and `Money.from_amount(amount, currency)` constructors
- Arithmetic operations: `+`, `-`, `*`, `/`, negation, `abs`
- Banker's rounding (round half to even) for multiplication and division
- Fair allocation via `allocate(ratios)` using largest remainder method
- Multi-currency formatting with `format(symbol:, code:, thousands:)`
- Currency conversion with `convert_to(target, rate:)`
- 30 built-in currencies including zero-decimal (JPY, KRW)
- Comparable interface for same-currency comparison
- Immutable (frozen) objects with `hash` and `eql?` for use as hash keys
