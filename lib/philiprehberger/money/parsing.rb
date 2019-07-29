# frozen_string_literal: true

module Philiprehberger
  class Money
    # Parsing formatted money strings back into Money objects
    module Parsing
      # Parse a formatted money string into a Money object
      #
      # @param input [String] formatted money string (e.g. "$1,234.56", "1.234,56 EUR")
      # @param currency [Symbol, String, nil] optional currency code override
      # @return [Money] parsed money object
      # @raise [ParseError] if the string cannot be parsed
      def self.parse(input, currency: nil)
        str = input.to_s.strip
        raise ParseError, 'Cannot parse empty string as money' if str.empty?

        detected_currency = currency ? Currency.find(currency) : detect_currency(str)
        raise ParseError, "Cannot detect currency from: #{input}" unless detected_currency

        cleaned = extract_numeric(str, detected_currency)
        raise ParseError, "Cannot parse amount from: #{input}" if cleaned.empty?

        negative = str.match?(/^-/) || str.match?(/\(-?\d/)
        amount = BigDecimal(cleaned)
        amount = -amount if negative

        cents = (amount * detected_currency.subunit_to_unit).round(0, BigDecimal::ROUND_HALF_EVEN).to_i
        Money.new(cents, detected_currency.code)
      end

      # Detect currency from symbol or code in the string
      #
      # @param str [String] the input string
      # @return [Currency, nil] detected currency or nil
      def self.detect_currency(str)
        # Try matching a trailing currency code (e.g. "1234 USD")
        if str.match?(/[A-Z]{3}\s*$/)
          code = str[/([A-Z]{3})\s*$/, 1]
          begin
            return Currency.find(code)
          rescue InvalidCurrency
            # not a valid code, continue
          end
        end

        # Try matching a leading currency code (e.g. "USD 1234")
        if str.match?(/^\s*[A-Z]{3}\b/)
          code = str[/^\s*([A-Z]{3})\b/, 1]
          begin
            return Currency.find(code)
          rescue InvalidCurrency
            # not a valid code, continue
          end
        end

        # Try matching by symbol — prefer longer symbols first to avoid
        # matching '$' when 'R$' is present
        all_currencies.sort_by { |c| -c.symbol.length }.each do |curr|
          return curr if str.include?(curr.symbol)
        end

        nil
      end

      # Extract the numeric portion of a money string
      #
      # @param str [String] the input string
      # @param curr [Currency] the currency for parsing rules
      # @return [String] cleaned numeric string suitable for BigDecimal
      def self.extract_numeric(str, curr)
        # Remove currency symbol, code, and whitespace around them
        cleaned = str.dup
        cleaned = cleaned.gsub(curr.symbol, '') unless curr.symbol.empty?
        cleaned = cleaned.gsub(/[A-Z]{3}/, '')
        cleaned = cleaned.gsub(/[()]/, '')
        cleaned = cleaned.strip
        cleaned = cleaned.delete('-')

        # Remove thousands separators and normalize decimal separator
        cleaned = cleaned.gsub(curr.thousands_separator, '') unless curr.thousands_separator.empty?
        cleaned = cleaned.gsub(curr.decimal_separator, '.') if curr.decimal_separator != '.'

        # Strip anything that is not a digit or period
        cleaned.gsub(/[^\d.]/, '')
      end

      # @return [Array<Currency>] all registered currencies
      def self.all_currencies
        Currency::REGISTRY.values + Currency.custom_currencies.values
      end

      private_class_method :detect_currency, :extract_numeric, :all_currencies
    end
  end
end
