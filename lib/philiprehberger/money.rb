# frozen_string_literal: true

require 'bigdecimal'

require_relative 'money/version'
require_relative 'money/currency'
require_relative 'money/arithmetic'
require_relative 'money/formatting'
require_relative 'money/allocation'

module Philiprehberger
  # Immutable money value object with integer subunit storage
  class Money
    include Comparable

    class Error < StandardError; end
    class CurrencyMismatch < Error; end
    class InvalidCurrency < Error; end

    attr_reader :cents, :currency

    # Create a Money object from subunit cents
    #
    # @param cents [Integer] amount in subunits (e.g. cents for USD)
    # @param currency_code [Symbol, String] ISO 4217 currency code
    # @return [Money]
    def initialize(cents, currency_code)
      @cents = Integer(cents)
      @currency = Currency.find(currency_code)
      freeze
    end

    # Create a Money object from a decimal amount
    #
    # @param amount [Numeric, String] decimal amount (e.g. 19.99)
    # @param currency_code [Symbol, String] ISO 4217 currency code
    # @return [Money]
    def self.from_amount(amount, currency_code)
      curr = Currency.find(currency_code)
      new((BigDecimal(amount.to_s) * curr.subunit_to_unit).round(0, BigDecimal::ROUND_HALF_EVEN).to_i, currency_code)
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

    include Arithmetic
    include Formatting
    include Allocation
  end
end
