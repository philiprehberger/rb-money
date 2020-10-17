# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Money::ExchangeRate do
  before { described_class.reset! }

  describe '.store' do
    it 'returns a singleton instance' do
      expect(described_class.store).to be_a(described_class)
      expect(described_class.store).to equal(described_class.store)
    end
  end

  describe '#set and #get' do
    it 'stores and retrieves a rate' do
      described_class.store.set(:USD, :EUR, 0.85)
      expect(described_class.store.get(:USD, :EUR)).to eq(BigDecimal('0.85'))
    end

    it 'returns inverse rate when direct is not set' do
      described_class.store.set(:USD, :EUR, 0.85)
      inverse = described_class.store.get(:EUR, :USD)
      expect(inverse).to be_within(0.001).of(BigDecimal('1') / BigDecimal('0.85'))
    end

    it 'returns 1 for same currency' do
      expect(described_class.store.get(:USD, :USD)).to eq(BigDecimal('1'))
    end

    it 'raises for unknown rate' do
      expect { described_class.store.get(:USD, :JPY) }.to raise_error(Philiprehberger::Money::Error)
    end

    it 'raises for non-positive rate' do
      expect { described_class.store.set(:USD, :EUR, 0) }.to raise_error(Philiprehberger::Money::Error)
      expect { described_class.store.set(:USD, :EUR, -1) }.to raise_error(Philiprehberger::Money::Error)
    end
  end

  describe '#clear' do
    it 'removes all rates' do
      described_class.store.set(:USD, :EUR, 0.85)
      described_class.store.clear
      expect { described_class.store.get(:USD, :EUR) }.to raise_error(Philiprehberger::Money::Error)
    end
  end

  describe '#exchange_to' do
    before { described_class.store.set(:USD, :EUR, 0.85) }

    it 'converts using the store rate' do
      money = Philiprehberger::Money.new(1000, :USD)
      result = money.exchange_to(:EUR)
      expect(result.currency.code.to_s.upcase).to eq('EUR')
      expect(result.cents).to eq(850)
    end
  end

  describe '.sum' do
    before { described_class.store.set(:USD, :EUR, 0.85) }

    it 'sums same-currency amounts' do
      moneys = [Philiprehberger::Money.new(100, :USD), Philiprehberger::Money.new(200, :USD)]
      result = Philiprehberger::Money.sum(moneys, target_currency: :USD)
      expect(result.cents).to eq(300)
    end

    it 'converts and sums mixed currencies' do
      moneys = [Philiprehberger::Money.new(1000, :USD), Philiprehberger::Money.new(850, :EUR)]
      result = Philiprehberger::Money.sum(moneys, target_currency: :USD)
      expect(result.cents).to eq(2000)
    end

    it 'raises for empty collection' do
      expect { Philiprehberger::Money.sum([], target_currency: :USD) }.to raise_error(Philiprehberger::Money::Error)
    end
  end

  describe '#round_to_nearest' do
    it 'rounds to nearest 5 cents' do
      money = Philiprehberger::Money.new(123, :USD)
      expect(money.round_to_nearest(5).cents).to eq(125)
    end

    it 'rounds to nearest 10 cents' do
      money = Philiprehberger::Money.new(124, :USD)
      expect(money.round_to_nearest(10).cents).to eq(120)
    end

    it 'raises for non-positive increment' do
      money = Philiprehberger::Money.new(100, :USD)
      expect { money.round_to_nearest(0) }.to raise_error(Philiprehberger::Money::Error)
    end
  end
end
