# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Money::Currency do
  describe '.find' do
    it 'finds USD by symbol' do
      currency = described_class.find(:usd)
      expect(currency.code).to eq(:usd)
      expect(currency.name).to eq('US Dollar')
      expect(currency.symbol).to eq('$')
      expect(currency.subunit_to_unit).to eq(100)
    end

    it 'finds currency by uppercase string' do
      currency = described_class.find('EUR')
      expect(currency.code).to eq(:eur)
    end

    it 'finds currency by lowercase string' do
      currency = described_class.find('gbp')
      expect(currency.code).to eq(:gbp)
    end

    it 'raises InvalidCurrency for unknown code' do
      expect { described_class.find(:zzz) }.to raise_error(Philiprehberger::Money::InvalidCurrency)
    end
  end

  describe 'zero-decimal currencies' do
    it 'JPY has subunit_to_unit of 1' do
      jpy = described_class.find(:jpy)
      expect(jpy.subunit_to_unit).to eq(1)
    end

    it 'KRW has subunit_to_unit of 1' do
      krw = described_class.find(:krw)
      expect(krw.subunit_to_unit).to eq(1)
    end
  end

  describe 'currency registry' do
    it 'contains 30 currencies' do
      expect(described_class::REGISTRY.size).to eq(30)
    end

    it 'is frozen' do
      expect(described_class::REGISTRY).to be_frozen
    end

    %i[usd eur gbp jpy cad aud chf cny inr brl mxn krw sek nok dkk
       pln czk huf try zar nzd sgd hkd twd thb rub ils aed sar php].each do |code|
      it "includes #{code.upcase}" do
        expect(described_class::REGISTRY).to have_key(code)
      end
    end
  end

  describe 'formatting attributes' do
    it 'USD has symbol_first true' do
      expect(described_class.find(:usd).symbol_first).to be true
    end

    it 'SEK has symbol_first false' do
      expect(described_class.find(:sek).symbol_first).to be false
    end

    it 'EUR uses comma as decimal separator' do
      expect(described_class.find(:eur).decimal_separator).to eq(',')
    end
  end

  describe 'immutability' do
    it 'currency objects are frozen' do
      expect(described_class.find(:usd)).to be_frozen
    end
  end

  describe '.register' do
    after do
      described_class.reset_custom_currencies!
    end

    it 'registers a new custom currency' do
      described_class.register(code: 'XTS', name: 'Test Currency', symbol: 'T$', subunit_to_unit: 100)
      currency = described_class.find(:xts)
      expect(currency.code).to eq(:xts)
      expect(currency.name).to eq('Test Currency')
      expect(currency.symbol).to eq('T$')
      expect(currency.subunit_to_unit).to eq(100)
    end

    it 'allows custom formatting options' do
      described_class.register(
        code: 'XYZ',
        name: 'Custom',
        symbol: 'X',
        subunit_to_unit: 1000,
        symbol_first: false,
        decimal_separator: ',',
        thousands_separator: '.'
      )
      currency = described_class.find(:xyz)
      expect(currency.symbol_first).to be false
      expect(currency.decimal_separator).to eq(',')
      expect(currency.thousands_separator).to eq('.')
      expect(currency.subunit_to_unit).to eq(1000)
    end

    it 'custom currencies work with Money operations' do
      described_class.register(code: 'XTC', name: 'Test Coin', symbol: 'TC', subunit_to_unit: 100)
      money = Philiprehberger::Money.from_amount(19.99, :xtc)
      expect(money.cents).to eq(1999)
      expect(money.format).to eq('TC19.99')
    end

    it 'raises ArgumentError for code shorter than 3 letters' do
      expect do
        described_class.register(code: 'AB', name: 'Bad', symbol: 'B')
      end.to raise_error(ArgumentError, /3 or more uppercase letters/)
    end

    it 'raises ArgumentError for code with non-letter characters' do
      expect do
        described_class.register(code: 'X1Z', name: 'Bad', symbol: 'B')
      end.to raise_error(ArgumentError, /3 or more uppercase letters/)
    end

    it 'raises ArgumentError for non-positive subunit_to_unit' do
      expect do
        described_class.register(code: 'XAA', name: 'Bad', symbol: 'B', subunit_to_unit: 0)
      end.to raise_error(ArgumentError, /positive integer/)
    end

    it 'raises ArgumentError for negative subunit_to_unit' do
      expect do
        described_class.register(code: 'XAA', name: 'Bad', symbol: 'B', subunit_to_unit: -1)
      end.to raise_error(ArgumentError, /positive integer/)
    end

    it 'raises ArgumentError when code already exists in built-in registry' do
      expect do
        described_class.register(code: 'USD', name: 'Duplicate', symbol: '$')
      end.to raise_error(ArgumentError, /already registered/)
    end

    it 'raises ArgumentError when code already exists in custom registry' do
      described_class.register(code: 'XNW', name: 'First', symbol: 'F')
      expect do
        described_class.register(code: 'XNW', name: 'Second', symbol: 'S')
      end.to raise_error(ArgumentError, /already registered/)
    end

    it 'registered currency objects are frozen' do
      described_class.register(code: 'XFZ', name: 'Frozen', symbol: 'FZ')
      expect(described_class.find(:xfz)).to be_frozen
    end
  end
end
