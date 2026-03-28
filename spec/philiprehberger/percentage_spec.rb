# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Money percentage operations' do
  describe '#percent' do
    it 'returns 15% of $100.00' do
      money = Philiprehberger::Money.new(10_000, :usd)
      result = money.percent(15)
      expect(result.cents).to eq(1500)
      expect(result.currency.code).to eq(:usd)
    end

    it 'returns 50% of $10.00' do
      money = Philiprehberger::Money.new(1000, :usd)
      result = money.percent(50)
      expect(result.cents).to eq(500)
    end

    it 'returns 0% of any amount' do
      money = Philiprehberger::Money.new(1000, :usd)
      result = money.percent(0)
      expect(result.cents).to eq(0)
    end

    it 'returns 100% of the amount' do
      money = Philiprehberger::Money.new(1000, :usd)
      result = money.percent(100)
      expect(result.cents).to eq(1000)
    end

    it 'handles fractional percentages with banker rounding' do
      money = Philiprehberger::Money.new(1000, :usd)
      result = money.percent(33.33)
      expect(result.cents).to eq(333)
    end

    it 'handles negative amounts' do
      money = Philiprehberger::Money.new(-1000, :usd)
      result = money.percent(10)
      expect(result.cents).to eq(-100)
    end

    it 'handles zero amount' do
      money = Philiprehberger::Money.new(0, :usd)
      result = money.percent(50)
      expect(result.cents).to eq(0)
    end

    it 'handles single cent' do
      money = Philiprehberger::Money.new(1, :usd)
      result = money.percent(50)
      expect(result.cents).to eq(0)
    end

    it 'uses banker rounding for half-even' do
      # 5 * 50 / 100 = 2.5 -> rounds to 2 (banker's)
      money = Philiprehberger::Money.new(5, :usd)
      result = money.percent(50)
      expect(result.cents).to eq(2)
    end
  end

  describe '#add_percent' do
    it 'adds 20% tax to $100.00' do
      money = Philiprehberger::Money.new(10_000, :usd)
      result = money.add_percent(20)
      expect(result.cents).to eq(12_000)
    end

    it 'adds 0% and returns the same amount' do
      money = Philiprehberger::Money.new(1000, :usd)
      result = money.add_percent(0)
      expect(result.cents).to eq(1000)
    end

    it 'works with negative amounts' do
      money = Philiprehberger::Money.new(-1000, :usd)
      result = money.add_percent(10)
      expect(result.cents).to eq(-1100)
    end

    it 'returns a new Money object' do
      money = Philiprehberger::Money.new(1000, :usd)
      result = money.add_percent(10)
      expect(result).not_to equal(money)
    end
  end

  describe '#subtract_percent' do
    it 'subtracts 25% discount from $100.00' do
      money = Philiprehberger::Money.new(10_000, :usd)
      result = money.subtract_percent(25)
      expect(result.cents).to eq(7500)
    end

    it 'subtracts 0% and returns the same amount' do
      money = Philiprehberger::Money.new(1000, :usd)
      result = money.subtract_percent(0)
      expect(result.cents).to eq(1000)
    end

    it 'subtracts 100% and returns zero' do
      money = Philiprehberger::Money.new(1000, :usd)
      result = money.subtract_percent(100)
      expect(result.cents).to eq(0)
    end

    it 'works with negative amounts' do
      money = Philiprehberger::Money.new(-1000, :usd)
      result = money.subtract_percent(10)
      expect(result.cents).to eq(-900)
    end
  end
end
