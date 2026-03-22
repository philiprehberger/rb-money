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
end
