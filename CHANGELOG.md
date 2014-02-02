# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
