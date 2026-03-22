# frozen_string_literal: true

module Philiprehberger
  class Money
    # Formatting methods for Money objects
    module Formatting
      # Format the money amount as a string
      #
      # @param symbol [Boolean] include the currency symbol (default: true)
      # @param code [Boolean] append the currency code (default: false)
      # @param thousands [Boolean] include thousands separators (default: true)
      # @return [String] formatted money string
      def format(symbol: true, code: false, thousands: true)
        formatted = format_amount(thousands: thousands)
        result = build_formatted_string(formatted, symbol: symbol)
        result = "#{result} #{currency.code.upcase}" if code
        result
      end

      # @return [String] formatted money string (delegates to #format)
      def to_s
        format
      end

      private

      def format_amount(thousands:)
        if currency.subunit_to_unit == 1
          integer_part = cents.abs.to_s
          apply_thousands(integer_part, thousands: thousands)
        else
          decimal_places = Math.log10(currency.subunit_to_unit).to_i
          abs_cents = cents.abs
          integer_part = (abs_cents / currency.subunit_to_unit).to_s
          fractional_part = (abs_cents % currency.subunit_to_unit).to_s.rjust(decimal_places, '0')
          formatted_integer = apply_thousands(integer_part, thousands: thousands)
          "#{formatted_integer}#{currency.decimal_separator}#{fractional_part}"
        end
      end

      def apply_thousands(integer_str, thousands:)
        return integer_str unless thousands && integer_str.length > 3

        integer_str.reverse.gsub(/(\d{3})(?=\d)/, "\\1#{currency.thousands_separator}").reverse
      end

      def build_formatted_string(formatted, symbol:)
        prefix = negative? ? '-' : ''
        if symbol
          if currency.symbol_first
            "#{prefix}#{currency.symbol}#{formatted}"
          else
            "#{prefix}#{formatted} #{currency.symbol}"
          end
        else
          "#{prefix}#{formatted}"
        end
      end
    end
  end
end
