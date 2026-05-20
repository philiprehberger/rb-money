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

      # Multiply by a numeric value using the stored rounding mode
      #
      # @param numeric [Numeric] the multiplier
      # @return [Money] a new Money with the product
      def *(other)
        mode = ROUNDING_MODES.fetch(rounding_mode, BigDecimal::ROUND_HALF_EVEN)
        result = (BigDecimal(cents.to_s) * BigDecimal(other.to_s)).round(0, mode).to_i
        self.class.new(result, currency.code, rounding: rounding_mode)
      end

      # Divide by a numeric value using the stored rounding mode
      #
      # @param numeric [Numeric] the divisor
      # @return [Money] a new Money with the quotient
      def /(other)
        mode = ROUNDING_MODES.fetch(rounding_mode, BigDecimal::ROUND_HALF_EVEN)
        result = (BigDecimal(cents.to_s) / BigDecimal(other.to_s)).round(0, mode).to_i
        self.class.new(result, currency.code, rounding: rounding_mode)
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

      # Return the total cost of this amount applied `times` consecutive times.
      # Functionally equivalent to multiplying by `times`, with two differences
      # that make it safer for billing flows:
      # - it requires a non-negative integer (callers cannot accidentally
      #   request a fractional or negative number of charges), and
      # - it documents intent at the call site (e.g. monthly fee × 12).
      #
      # @param times [Integer] number of times the amount is applied (>= 0)
      # @return [Money] a new Money totalling this amount × `times`
      # @raise [ArgumentError] if `times` is not a non-negative Integer
      def recurring(times)
        raise ArgumentError, "times must be an Integer (got #{times.class})" unless times.is_a?(Integer)
        raise ArgumentError, "times must be non-negative (got #{times})" if times.negative?

        self.class.new(cents * times, currency.code, rounding: rounding_mode)
      end

      # Return a new Money with the value rounded to the given decimal precision
      #
      # When +precision+ is +nil+, the currency's exponent is used (a no-op for
      # standard same-precision storage). Rounding less precision than the
      # currency exponent reduces the number of significant decimals (e.g.
      # USD 1.234 rounded to precision 1 becomes 1.2, i.e. $1.20).
      #
      # @param precision [Integer, nil] number of decimal places to round to
      # @return [Money] a new Money in the same currency
      def round(precision = nil)
        precision = currency.exponent if precision.nil?
        rounded_amount = to_f.round(precision)
        self.class.from_amount(rounded_amount, currency.code, rounding: rounding_mode)
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
