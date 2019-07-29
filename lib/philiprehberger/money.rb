# frozen_string_literal: true

require 'bigdecimal'

require_relative 'money/version'
require_relative 'money/currency'
require_relative 'money/arithmetic'
require_relative 'money/formatting'
require_relative 'money/allocation'
require_relative 'money/parsing'

module Philiprehberger
  # Immutable money value object with integer subunit storage
  class Money
    include Comparable

    class Error < StandardError; end
    class CurrencyMismatch < Error; end
    class InvalidCurrency < Error; end
    class ParseError < Error; end

    ROUNDING_MODES = {
      half_even: BigDecimal::ROUND_HALF_EVEN,
      half_up: BigDecimal::ROUND_HALF_UP,
      ceil: BigDecimal::ROUND_CEILING,
      floor: BigDecimal::ROUND_FLOOR
    }.freeze

    attr_reader :cents, :currency, :rounding_mode

    # Create a Money object from subunit cents
    #
    # @param cents [Integer] amount in subunits (e.g. cents for USD)
    # @param currency_code [Symbol, String] ISO 4217 currency code
    # @param rounding [Symbol] rounding mode (:half_even, :half_up, :ceil, :floor)
    # @return [Money]
    def initialize(cents, currency_code, rounding: :half_even)
      @cents = Integer(cents)
      @currency = Currency.find(currency_code)
      @rounding_mode = rounding
      freeze
    end

    # Create a Money object from a decimal amount
    #
    # @param amount [Numeric, String] decimal amount (e.g. 19.99)
    # @param currency_code [Symbol, String] ISO 4217 currency code
    # @param rounding [Symbol] rounding mode (:half_even, :half_up, :ceil, :floor)
    # @return [Money]
    def self.from_amount(amount, currency_code, rounding: :half_even)
      curr = Currency.find(currency_code)
      mode = ROUNDING_MODES.fetch(rounding) do
        raise ArgumentError, "Unknown rounding mode: #{rounding}. Valid modes: #{ROUNDING_MODES.keys.join(', ')}"
      end
      new(
        (BigDecimal(amount.to_s) * curr.subunit_to_unit).round(0, mode).to_i,
        currency_code,
        rounding: rounding
      )
    end

    # Parse a formatted money string into a Money object
    #
    # @param input [String] formatted money string
    # @param currency [Symbol, String, nil] optional currency code
    # @return [Money]
    # @raise [ParseError] if the string cannot be parsed
    def self.parse(input, currency: nil)
      Parsing.parse(input, currency: currency)
    end

    # The decimal amount
    #
    # @return [BigDecimal]
    def amount
      BigDecimal(@cents.to_s) / @currency.subunit_to_unit
    end

    # The decimal amount as a float
    #
    # @return [Float]
    def to_f
      amount.to_f
    end

    # Compare two Money objects of the same currency
    #
    # @param other [Money]
    # @return [Integer, nil] -1, 0, 1, or nil if currencies differ
    def <=>(other)
      return nil unless other.is_a?(Money) && other.currency.code == currency.code

      cents <=> other.cents
    end

    # @return [Boolean] true if the amount is zero
    def zero?
      @cents.zero?
    end

    # @return [Boolean] true if the amount is positive
    def positive?
      @cents.positive?
    end

    # @return [Boolean] true if the amount is negative
    def negative?
      @cents.negative?
    end

    # Convert to another currency using a given rate
    #
    # @param target_code [Symbol, String] target currency code
    # @param rate [Numeric] exchange rate (e.g. 1.25)
    # @return [Money] new Money in the target currency
    def convert_to(target_code, rate:)
      Currency.find(target_code)
      converted = (BigDecimal(@cents.to_s) * BigDecimal(rate.to_s)).round(0, BigDecimal::ROUND_HALF_EVEN).to_i
      self.class.new(converted, target_code)
    end

    # @return [Integer] hash based on cents and currency code
    def hash
      [@cents, @currency.code].hash
    end

    # @param other [Object]
    # @return [Boolean] true if same cents and currency
    def eql?(other)
      other.is_a?(Money) && cents == other.cents && currency.code == other.currency.code
    end

    # Return n% of this money amount
    #
    # @param n [Numeric] percentage (e.g. 15 for 15%)
    # @return [Money] n% of the amount
    def percent(n)
      result = (BigDecimal(cents.to_s) * BigDecimal(n.to_s) / BigDecimal('100'))
               .round(0, BigDecimal::ROUND_HALF_EVEN).to_i
      self.class.new(result, currency.code)
    end

    # Return money plus n% (e.g. for tax-inclusive pricing)
    #
    # @param n [Numeric] percentage to add
    # @return [Money] money + n%
    def add_percent(n)
      self + percent(n)
    end

    # Return money minus n% (e.g. for discounts)
    #
    # @param n [Numeric] percentage to subtract
    # @return [Money] money - n%
    def subtract_percent(n)
      self - percent(n)
    end

    # Split money equally among n parts
    #
    # @param n [Integer] number of parts
    # @return [Array<Money>] array of Money objects that sum to the original
    # @raise [ArgumentError] if n < 1
    def split(n)
      raise ArgumentError, 'Number of parts must be 1 or more' unless n.is_a?(Integer) && n >= 1

      allocate(Array.new(n, 1))
    end

    include Arithmetic
    include Formatting
    include Allocation
  end
end
