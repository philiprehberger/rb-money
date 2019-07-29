# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Money#split' do
  describe '#split' do
    it 'splits $10.00 into 3 equal parts' do
      money = Philiprehberger::Money.new(1000, :usd)
      parts = money.split(3)
      expect(parts.length).to eq(3)
      expect(parts.map(&:cents)).to eq([334, 333, 333])
      expect(parts.sum(&:cents)).to eq(1000)
    end

    it 'splits $1.00 into 2 parts' do
      money = Philiprehberger::Money.new(100, :usd)
      parts = money.split(2)
      expect(parts.length).to eq(2)
      expect(parts.sum(&:cents)).to eq(100)
    end

    it 'splits $0.01 into 1 part' do
      money = Philiprehberger::Money.new(1, :usd)
      parts = money.split(1)
      expect(parts.length).to eq(1)
      expect(parts.first.cents).to eq(1)
    end

    it 'splits zero amount' do
      money = Philiprehberger::Money.new(0, :usd)
      parts = money.split(3)
      expect(parts.length).to eq(3)
      expect(parts.map(&:cents)).to eq([0, 0, 0])
    end

    it 'preserves currency' do
      money = Philiprehberger::Money.new(1000, :eur)
      parts = money.split(2)
      parts.each { |p| expect(p.currency.code).to eq(:eur) }
    end

    it 'ensures no money is lost for odd splits' do
      money = Philiprehberger::Money.new(10, :usd)
      parts = money.split(3)
      expect(parts.sum(&:cents)).to eq(10)
    end

    it 'handles negative amounts' do
      money = Philiprehberger::Money.new(-100, :usd)
      parts = money.split(3)
      expect(parts.sum(&:cents)).to eq(-100)
    end

    it 'is equivalent to allocate with equal ratios' do
      money = Philiprehberger::Money.new(1001, :usd)
      split_parts = money.split(3)
      allocate_parts = money.allocate([1, 1, 1])
      expect(split_parts.map(&:cents)).to eq(allocate_parts.map(&:cents))
    end

    it 'raises ArgumentError if n < 1' do
      money = Philiprehberger::Money.new(1000, :usd)
      expect { money.split(0) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError if n is negative' do
      money = Philiprehberger::Money.new(1000, :usd)
      expect { money.split(-1) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError if n is not an integer' do
      money = Philiprehberger::Money.new(1000, :usd)
      expect { money.split(2.5) }.to raise_error(ArgumentError)
    end
  end
end
