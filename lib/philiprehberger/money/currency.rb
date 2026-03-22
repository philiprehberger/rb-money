# frozen_string_literal: true

module Philiprehberger
  class Money
    # Represents a currency with formatting rules and subunit information
    class Currency
      attr_reader :code, :name, :symbol, :subunit_to_unit, :symbol_first, :decimal_separator, :thousands_separator

      # @param code [Symbol] ISO 4217 currency code (lowercase)
      # @param name [String] full currency name
      # @param symbol [String] currency symbol
      # @param subunit_to_unit [Integer] number of subunits per unit (100 for cents, 1 for zero-decimal)
      # @param symbol_first [Boolean] whether the symbol appears before the amount
      # @param decimal_separator [String] character separating decimals
      # @param thousands_separator [String] character separating thousands
      def initialize(code:, name:, symbol:, subunit_to_unit:, symbol_first: true,
                     decimal_separator: '.', thousands_separator: ',')
        @code = code
        @name = name
        @symbol = symbol
        @subunit_to_unit = subunit_to_unit
        @symbol_first = symbol_first
        @decimal_separator = decimal_separator
        @thousands_separator = thousands_separator
        freeze
      end

      # Find a currency by its code
      #
      # @param code [Symbol, String] currency code (e.g. :usd, "USD")
      # @return [Currency]
      # @raise [Philiprehberger::Money::InvalidCurrency] if currency is not found
      def self.find(code)
        key = code.to_s.downcase.to_sym
        REGISTRY.fetch(key) do
          raise Philiprehberger::Money::InvalidCurrency, "Unknown currency: #{code}"
        end
      end

      REGISTRY = {
        usd: new(code: :usd, name: 'US Dollar', symbol: '$', subunit_to_unit: 100),
        eur: new(code: :eur, name: 'Euro', symbol: "\u20AC", subunit_to_unit: 100, symbol_first: true,
                 decimal_separator: ',', thousands_separator: '.'),
        gbp: new(code: :gbp, name: 'British Pound', symbol: "\u00A3", subunit_to_unit: 100),
        jpy: new(code: :jpy, name: 'Japanese Yen', symbol: "\u00A5", subunit_to_unit: 1),
        cad: new(code: :cad, name: 'Canadian Dollar', symbol: '$', subunit_to_unit: 100),
        aud: new(code: :aud, name: 'Australian Dollar', symbol: '$', subunit_to_unit: 100),
        chf: new(code: :chf, name: 'Swiss Franc', symbol: 'CHF', subunit_to_unit: 100, symbol_first: true,
                 decimal_separator: '.', thousands_separator: "'"),
        cny: new(code: :cny, name: 'Chinese Yuan', symbol: "\u00A5", subunit_to_unit: 100),
        inr: new(code: :inr, name: 'Indian Rupee', symbol: "\u20B9", subunit_to_unit: 100),
        brl: new(code: :brl, name: 'Brazilian Real', symbol: 'R$', subunit_to_unit: 100, symbol_first: true,
                 decimal_separator: ',', thousands_separator: '.'),
        mxn: new(code: :mxn, name: 'Mexican Peso', symbol: '$', subunit_to_unit: 100),
        krw: new(code: :krw, name: 'South Korean Won', symbol: "\u20A9", subunit_to_unit: 1),
        sek: new(code: :sek, name: 'Swedish Krona', symbol: 'kr', subunit_to_unit: 100, symbol_first: false,
                 decimal_separator: ',', thousands_separator: ' '),
        nok: new(code: :nok, name: 'Norwegian Krone', symbol: 'kr', subunit_to_unit: 100, symbol_first: false,
                 decimal_separator: ',', thousands_separator: ' '),
        dkk: new(code: :dkk, name: 'Danish Krone', symbol: 'kr', subunit_to_unit: 100, symbol_first: false,
                 decimal_separator: ',', thousands_separator: '.'),
        pln: new(code: :pln, name: 'Polish Zloty', symbol: "z\u0142", subunit_to_unit: 100, symbol_first: false,
                 decimal_separator: ',', thousands_separator: ' '),
        czk: new(code: :czk, name: 'Czech Koruna', symbol: "K\u010D", subunit_to_unit: 100, symbol_first: false,
                 decimal_separator: ',', thousands_separator: ' '),
        huf: new(code: :huf, name: 'Hungarian Forint', symbol: 'Ft', subunit_to_unit: 100, symbol_first: false,
                 decimal_separator: ',', thousands_separator: ' '),
        try: new(code: :try, name: 'Turkish Lira', symbol: "\u20BA", subunit_to_unit: 100),
        zar: new(code: :zar, name: 'South African Rand', symbol: 'R', subunit_to_unit: 100),
        nzd: new(code: :nzd, name: 'New Zealand Dollar', symbol: '$', subunit_to_unit: 100),
        sgd: new(code: :sgd, name: 'Singapore Dollar', symbol: '$', subunit_to_unit: 100),
        hkd: new(code: :hkd, name: 'Hong Kong Dollar', symbol: 'HK$', subunit_to_unit: 100),
        twd: new(code: :twd, name: 'New Taiwan Dollar', symbol: 'NT$', subunit_to_unit: 100),
        thb: new(code: :thb, name: 'Thai Baht', symbol: "\u0E3F", subunit_to_unit: 100),
        rub: new(code: :rub, name: 'Russian Ruble', symbol: "\u20BD", subunit_to_unit: 100),
        ils: new(code: :ils, name: 'Israeli Shekel', symbol: "\u20AA", subunit_to_unit: 100),
        aed: new(code: :aed, name: 'UAE Dirham', symbol: "\u062F.\u0625", subunit_to_unit: 100),
        sar: new(code: :sar, name: 'Saudi Riyal', symbol: "\uFDFC", subunit_to_unit: 100),
        php: new(code: :php, name: 'Philippine Peso', symbol: "\u20B1", subunit_to_unit: 100)
      }.freeze
    end
  end
end
