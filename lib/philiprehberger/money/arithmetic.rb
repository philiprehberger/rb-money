# frozen_string_literal: true

module Philiprehberger
  class Money
    # Arithmetic operations for Money objects
    module Arithmetic
      # Add two Money objects of the same currency
      #
      # @param other [Money] the money to add
      # @return [Money] a new Money with the sum
      # @raise [CurrencyMismatch] if currencies differ
      def +(other)
        assert_same_currency!(other)
        self.class.new(cents + other.cents, currency.code)
      end

      # Subtract a Money object from this one
      #
      # @param other [Money] the money to subtract
      # @return [Money] a new Money with the difference
      # @raise [CurrencyMismatch] if currencies differ
      def -(other)
        assert_same_currency!(other)
        self.class.new(cents - other.cents, currency.code)
      end

      # Multiply by a numeric value using banker's rounding
      #
      # @param numeric [Numeric] the multiplier
      # @return [Money] a new Money with the product
      def *(numeric)
        result = (BigDecimal(cents.to_s) * BigDecimal(numeric.to_s)).round(0, :even).to_i
        self.class.new(result, currency.code)
      end

      # Divide by a numeric value using banker's rounding
      #
      # @param numeric [Numeric] the divisor
      # @return [Money] a new Money with the quotient
      def /(numeric)
        result = (BigDecimal(cents.to_s) / BigDecimal(numeric.to_s)).round(0, :even).to_i
        self.class.new(result, currency.code)
      end

      # Negate the amount
      #
      # @return [Money] a new Money with negated cents
      def -@
        self.class.new(-cents, currency.code)
      end

      # Absolute value
      #
      # @return [Money] a new Money with the absolute value of cents
      def abs
        self.class.new(cents.abs, currency.code)
      end

      private

      def assert_same_currency!(other)
        return if currency.code == other.currency.code

        raise CurrencyMismatch,
              "Cannot operate on #{currency.code.upcase} with #{other.currency.code.upcase}"
      end
    end
  end
end
