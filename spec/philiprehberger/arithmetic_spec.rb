# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Money::Arithmetic do
  let(:ten_usd) { Philiprehberger::Money.new(1000, :usd) }
  let(:five_usd) { Philiprehberger::Money.new(500, :usd) }
  let(:ten_eur) { Philiprehberger::Money.new(1000, :eur) }

  describe '#+' do
    it 'adds two money objects of the same currency' do
      result = ten_usd + five_usd
      expect(result.cents).to eq(1500)
      expect(result.currency.code).to eq(:usd)
    end

    it 'returns a new Money object' do
      result = ten_usd + five_usd
      expect(result).not_to equal(ten_usd)
    end

    it 'raises CurrencyMismatch for different currencies' do
      expect { ten_usd + ten_eur }.to raise_error(Philiprehberger::Money::CurrencyMismatch)
    end
  end

  describe '#-' do
    it 'subtracts two money objects of the same currency' do
      result = ten_usd - five_usd
      expect(result.cents).to eq(500)
    end

    it 'allows negative results' do
      result = five_usd - ten_usd
      expect(result.cents).to eq(-500)
    end

    it 'raises CurrencyMismatch for different currencies' do
      expect { ten_usd - ten_eur }.to raise_error(Philiprehberger::Money::CurrencyMismatch)
    end
  end

  describe '#*' do
    it 'multiplies by an integer' do
      result = ten_usd * 3
      expect(result.cents).to eq(3000)
    end

    it 'multiplies by a float with banker rounding' do
      money = Philiprehberger::Money.new(100, :usd)
      result = money * 1.5
      expect(result.cents).to eq(150)
    end

    it 'uses banker rounding (half to even) - rounds 2.5 to 2' do
      money = Philiprehberger::Money.new(5, :usd)
      result = money * 0.5
      expect(result.cents).to eq(2)
    end

    it 'uses banker rounding (half to even) - rounds 3.5 to 4' do
      money = Philiprehberger::Money.new(7, :usd)
      result = money * 0.5
      expect(result.cents).to eq(4)
    end
  end

  describe '#/' do
    it 'divides by an integer' do
      result = ten_usd / 2
      expect(result.cents).to eq(500)
    end

    it 'uses banker rounding on division' do
      money = Philiprehberger::Money.new(5, :usd)
      result = money / 2
      expect(result.cents).to eq(2)
    end

    it 'uses banker rounding (half to even) - rounds 3.5 to 4' do
      money = Philiprehberger::Money.new(7, :usd)
      result = money / 2
      expect(result.cents).to eq(4)
    end
  end

  describe '#-@' do
    it 'negates the amount' do
      result = -ten_usd
      expect(result.cents).to eq(-1000)
    end

    it 'double negation returns original amount' do
      result = -(-ten_usd)
      expect(result.cents).to eq(1000)
    end
  end

  describe '#abs' do
    it 'returns absolute value of positive money' do
      expect(ten_usd.abs.cents).to eq(1000)
    end

    it 'returns absolute value of negative money' do
      negative = Philiprehberger::Money.new(-1000, :usd)
      expect(negative.abs.cents).to eq(1000)
    end
  end

  describe '#round' do
    let(:money) { Philiprehberger::Money.new(1234, :usd) } # $12.34

    it 'returns a new Money instance (does not mutate)' do
      result = money.round(0)
      expect(result).not_to equal(money)
      expect(result).to be_a(Philiprehberger::Money)
      expect(money.cents).to eq(1234)
    end

    it 'keeps the original currency' do
      expect(money.round(0).currency.code).to eq(:usd)
    end

    it 'rounds to whole units with precision 0' do
      # $12.34 -> $12.00
      expect(money.round(0).cents).to eq(1200)
    end

    it 'rounds to nearest tenth with precision 1' do
      # $12.34 -> $12.30
      expect(money.round(1).cents).to eq(1230)
    end

    it 'rounds USD 1.234 to precision 1 -> $1.20' do
      # 1.234 rounded to 1 decimal -> 1.2 -> 120 cents
      m = Philiprehberger::Money.from_amount(1.234, :usd)
      expect(m.round(1).cents).to eq(120)
    end

    it 'defaults to currency exponent when precision is nil (no-op for matching precision)' do
      result = money.round
      expect(result.cents).to eq(money.cents)
      expect(result).not_to equal(money)
    end

    it 'rounds JPY (exponent 0) with default precision as a no-op' do
      jpy = Philiprehberger::Money.new(2000, :jpy)
      expect(jpy.round.cents).to eq(2000)
    end
  end
end
