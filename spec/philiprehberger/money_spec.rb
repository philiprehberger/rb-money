# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Money do
  describe 'VERSION' do
    it 'has a version number' do
      expect(Philiprehberger::Money::VERSION).not_to be_nil
    end

    it 'follows semantic versioning' do
      expect(Philiprehberger::Money::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
    end
  end

  describe '.new' do
    it 'creates money from cents and currency code' do
      money = described_class.new(1999, :usd)
      expect(money.cents).to eq(1999)
      expect(money.currency.code).to eq(:usd)
    end

    it 'accepts string currency codes' do
      money = described_class.new(500, 'USD')
      expect(money.currency.code).to eq(:usd)
    end

    it 'raises for invalid currency' do
      expect { described_class.new(100, :zzz) }.to raise_error(Philiprehberger::Money::InvalidCurrency)
    end

    it 'coerces cents to integer' do
      money = described_class.new('500', :usd)
      expect(money.cents).to eq(500)
    end
  end

  describe '.from_amount' do
    it 'creates money from a decimal amount' do
      money = described_class.from_amount(19.99, :usd)
      expect(money.cents).to eq(1999)
    end

    it 'creates money from a string amount' do
      money = described_class.from_amount('19.99', :usd)
      expect(money.cents).to eq(1999)
    end

    it 'handles zero-decimal currencies' do
      money = described_class.from_amount(2000, :jpy)
      expect(money.cents).to eq(2000)
    end

    it 'uses banker rounding for half-even amounts' do
      # 2.5 cents rounds to 2, 3.5 cents rounds to 4
      money_even = described_class.from_amount(0.025, :usd)
      expect(money_even.cents).to eq(2)

      money_odd = described_class.from_amount(0.035, :usd)
      expect(money_odd.cents).to eq(4)
    end
  end

  describe '#amount' do
    it 'returns the decimal amount as BigDecimal' do
      money = described_class.new(1999, :usd)
      expect(money.amount).to eq(BigDecimal('19.99'))
    end

    it 'returns whole number for zero-decimal currencies' do
      money = described_class.new(2000, :jpy)
      expect(money.amount).to eq(BigDecimal('2000'))
    end
  end

  describe '#to_f' do
    it 'returns the decimal amount as a float' do
      money = described_class.new(1999, :usd)
      expect(money.to_f).to be_within(0.001).of(19.99)
    end
  end

  describe 'comparison' do
    let(:ten_usd) { described_class.new(1000, :usd) }
    let(:twenty_usd) { described_class.new(2000, :usd) }
    let(:ten_eur) { described_class.new(1000, :eur) }

    it 'compares same-currency amounts' do
      expect(ten_usd).to be < twenty_usd
      expect(twenty_usd).to be > ten_usd
    end

    it 'considers equal amounts equal' do
      other_ten = described_class.new(1000, :usd)
      expect(ten_usd).to eq(other_ten)
    end

    it 'returns nil for different currencies' do
      expect(ten_usd <=> ten_eur).to be_nil
    end
  end

  describe 'predicates' do
    it '#zero? returns true for zero cents' do
      expect(described_class.new(0, :usd)).to be_zero
    end

    it '#zero? returns false for non-zero cents' do
      expect(described_class.new(100, :usd)).not_to be_zero
    end

    it '#positive? returns true for positive cents' do
      expect(described_class.new(100, :usd)).to be_positive
    end

    it '#negative? returns true for negative cents' do
      expect(described_class.new(-100, :usd)).to be_negative
    end
  end

  describe '#convert_to' do
    it 'converts to another currency using a rate' do
      usd = described_class.new(1000, :usd)
      eur = usd.convert_to(:eur, rate: 0.85)
      expect(eur.cents).to eq(850)
      expect(eur.currency.code).to eq(:eur)
    end

    it 'uses banker rounding on conversion' do
      usd = described_class.new(1001, :usd)
      eur = usd.convert_to(:eur, rate: 0.5)
      expect(eur.cents).to eq(500)
    end
  end

  describe 'immutability' do
    it 'is frozen after creation' do
      money = described_class.new(100, :usd)
      expect(money).to be_frozen
    end
  end

  describe '#hash and #eql?' do
    it 'produces equal hashes for equal money' do
      a = described_class.new(100, :usd)
      b = described_class.new(100, :usd)
      expect(a.hash).to eq(b.hash)
    end

    it 'is eql? for same cents and currency' do
      a = described_class.new(100, :usd)
      b = described_class.new(100, :usd)
      expect(a).to eql(b)
    end

    it 'is not eql? for different currencies' do
      a = described_class.new(100, :usd)
      b = described_class.new(100, :eur)
      expect(a).not_to eql(b)
    end

    it 'works as hash keys' do
      a = described_class.new(100, :usd)
      b = described_class.new(100, :usd)
      hash = { a => 'value' }
      expect(hash[b]).to eq('value')
    end
  end
end
