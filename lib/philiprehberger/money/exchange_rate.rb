# frozen_string_literal: true

module Philiprehberger
  class Money
    # Thread-safe exchange rate store for currency conversion.
    class ExchangeRate
      class << self
        def store
          @store ||= new
        end

        def reset!
          @store = new
        end
      end

      def initialize
        @rates = {}
        @mutex = Mutex.new
      end

      def set(from, to, rate)
        from_sym = from.to_s.upcase.to_sym
        to_sym = to.to_s.upcase.to_sym
        raise Money::Error, 'Rate must be positive' unless rate.is_a?(Numeric) && rate.positive?

        @mutex.synchronize do
          @rates[[from_sym, to_sym]] = BigDecimal(rate.to_s)
        end
        self
      end

      def get(from, to)
        from_sym = from.to_s.upcase.to_sym
        to_sym = to.to_s.upcase.to_sym
        return BigDecimal('1') if from_sym == to_sym

        @mutex.synchronize do
          rate = @rates[[from_sym, to_sym]]
          return rate if rate

          inverse = @rates[[to_sym, from_sym]]
          return BigDecimal('1') / inverse if inverse

          raise Money::Error, "No exchange rate found for #{from_sym} -> #{to_sym}"
        end
      end

      def clear
        @mutex.synchronize { @rates.clear }
        self
      end

      def rates_count
        @mutex.synchronize { @rates.size }
      end
    end
  end
end
