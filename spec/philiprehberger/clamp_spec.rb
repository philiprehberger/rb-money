# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Money do
  describe '#clamp' do
    let(:min) { described_class.new(500, :usd) }
    let(:max) { described_class.new(2000, :usd) }

    it 'returns self when within range' do
      money = described_class.new(1000, :usd)
      result = money.clamp(min, max)
      expect(result).to equal(money)
    end

    it 'returns min when below range' do
      money = described_class.new(100, :usd)
      result = money.clamp(min, max)
      expect(result).to equal(min)
    end

    it 'returns max when above range' do
      money = described_class.new(5000, :usd)
      result = money.clamp(min, max)
      expect(result).to equal(max)
    end

    it 'returns self when equal to min' do
      money = described_class.new(500, :usd)
      result = money.clamp(min, max)
      expect(result.cents).to eq(500)
    end

    it 'returns self when equal to max' do
      money = described_class.new(2000, :usd)
      result = money.clamp(min, max)
      expect(result.cents).to eq(2000)
    end

    it 'works when min equals max' do
      same = described_class.new(1000, :usd)
      money = described_class.new(500, :usd)
      result = money.clamp(same, same)
      expect(result.cents).to eq(1000)
    end

    it 'raises CurrencyMismatch when min has different currency' do
      eur_min = described_class.new(500, :eur)
      money = described_class.new(1000, :usd)
      expect { money.clamp(eur_min, max) }.to raise_error(Philiprehberger::Money::CurrencyMismatch)
    end

    it 'raises CurrencyMismatch when max has different currency' do
      eur_max = described_class.new(2000, :eur)
      money = described_class.new(1000, :usd)
      expect { money.clamp(min, eur_max) }.to raise_error(Philiprehberger::Money::CurrencyMismatch)
    end

    it 'raises ArgumentError when min is greater than max' do
      money = described_class.new(1000, :usd)
      expect { money.clamp(max, min) }.to raise_error(ArgumentError, /min must not be greater than max/)
    end

    it 'works with negative amounts' do
      neg_min = described_class.new(-1000, :usd)
      neg_max = described_class.new(-100, :usd)
      money = described_class.new(-2000, :usd)
      result = money.clamp(neg_min, neg_max)
      expect(result.cents).to eq(-1000)
    end
  end
end
