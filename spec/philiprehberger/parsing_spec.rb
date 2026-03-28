# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Money::Parsing do
  describe '.parse' do
    context 'with USD' do
      it 'parses "$19.99"' do
        money = Philiprehberger::Money.parse('$19.99')
        expect(money.cents).to eq(1999)
        expect(money.currency.code).to eq(:usd)
      end

      it 'parses "$1,234.56"' do
        money = Philiprehberger::Money.parse('$1,234.56')
        expect(money.cents).to eq(123_456)
        expect(money.currency.code).to eq(:usd)
      end

      it 'parses "1234.56 USD"' do
        money = Philiprehberger::Money.parse('1234.56 USD')
        expect(money.cents).to eq(123_456)
        expect(money.currency.code).to eq(:usd)
      end

      it 'parses "$0.01"' do
        money = Philiprehberger::Money.parse('$0.01')
        expect(money.cents).to eq(1)
      end

      it 'parses "$0.00"' do
        money = Philiprehberger::Money.parse('$0.00')
        expect(money.cents).to eq(0)
      end

      it 'parses negative amounts like "-$19.99"' do
        money = Philiprehberger::Money.parse('-$19.99')
        expect(money.cents).to eq(-1999)
      end
    end

    context 'with EUR' do
      it 'parses amounts with euro symbol' do
        money = Philiprehberger::Money.parse("\u20AC19,99")
        expect(money.cents).to eq(1999)
        expect(money.currency.code).to eq(:eur)
      end

      it 'parses "1.234,56 EUR"' do
        money = Philiprehberger::Money.parse('1.234,56 EUR')
        expect(money.cents).to eq(123_456)
        expect(money.currency.code).to eq(:eur)
      end
    end

    context 'with JPY (zero-decimal)' do
      it 'parses yen amounts' do
        money = Philiprehberger::Money.parse("\u00A52,000", currency: :jpy)
        expect(money.cents).to eq(2000)
        expect(money.currency.code).to eq(:jpy)
      end

      it 'parses "1234 JPY"' do
        money = Philiprehberger::Money.parse('1234 JPY')
        expect(money.cents).to eq(1234)
      end
    end

    context 'with GBP' do
      it 'parses pound amounts' do
        money = Philiprehberger::Money.parse("\u00A310.50")
        expect(money.cents).to eq(1050)
        expect(money.currency.code).to eq(:gbp)
      end
    end

    context 'with explicit currency override' do
      it 'uses provided currency instead of detecting' do
        money = Philiprehberger::Money.parse('$19.99', currency: :cad)
        expect(money.cents).to eq(1999)
        expect(money.currency.code).to eq(:cad)
      end
    end

    context 'round-trip consistency' do
      it 'parses a formatted USD amount back to the original' do
        original = Philiprehberger::Money.new(123_456, :usd)
        parsed = Philiprehberger::Money.parse(original.format, currency: :usd)
        expect(parsed).to eq(original)
      end

      it 'parses a formatted EUR amount back to the original' do
        original = Philiprehberger::Money.new(123_456, :eur)
        parsed = Philiprehberger::Money.parse(original.format, currency: :eur)
        expect(parsed).to eq(original)
      end

      it 'parses a formatted JPY amount back to the original' do
        original = Philiprehberger::Money.new(5000, :jpy)
        parsed = Philiprehberger::Money.parse(original.format, currency: :jpy)
        expect(parsed).to eq(original)
      end

      it 'parses a formatted GBP amount back to the original' do
        original = Philiprehberger::Money.new(9999, :gbp)
        parsed = Philiprehberger::Money.parse(original.format, currency: :gbp)
        expect(parsed).to eq(original)
      end
    end

    context 'error cases' do
      it 'raises ParseError for empty string' do
        expect { Philiprehberger::Money.parse('') }.to raise_error(Philiprehberger::Money::ParseError)
      end

      it 'raises ParseError for unrecognizable string' do
        expect { Philiprehberger::Money.parse('hello world') }.to raise_error(Philiprehberger::Money::ParseError)
      end

      it 'raises ParseError for whitespace only' do
        expect { Philiprehberger::Money.parse('   ') }.to raise_error(Philiprehberger::Money::ParseError)
      end
    end
  end
end
