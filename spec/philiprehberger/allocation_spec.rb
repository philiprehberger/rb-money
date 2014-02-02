# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Money::Allocation do
  describe '#allocate' do
    it 'splits money by equal ratios' do
      money = Philiprehberger::Money.new(1000, :usd)
      shares = money.allocate([1, 1, 1])
      expect(shares.map(&:cents)).to eq([334, 333, 333])
      expect(shares.sum(&:cents)).to eq(1000)
    end

    it 'splits money by percentage ratios' do
      money = Philiprehberger::Money.new(1000, :usd)
      shares = money.allocate([0.5, 0.3, 0.2])
      expect(shares.map(&:cents)).to eq([500, 300, 200])
      expect(shares.sum(&:cents)).to eq(1000)
    end

    it 'distributes remainder cents fairly' do
      money = Philiprehberger::Money.new(100, :usd)
      shares = money.allocate([1, 1, 1])
      expect(shares.map(&:cents)).to eq([34, 33, 33])
      expect(shares.sum(&:cents)).to eq(100)
    end

    it 'handles uneven splits with remainder' do
      money = Philiprehberger::Money.new(10, :usd)
      shares = money.allocate([1, 1, 1])
      expect(shares.sum(&:cents)).to eq(10)
    end

    it 'returns Money objects with the same currency' do
      money = Philiprehberger::Money.new(1000, :eur)
      shares = money.allocate([0.5, 0.5])
      shares.each do |share|
        expect(share.currency.code).to eq(:eur)
      end
    end

    it 'handles two-way split' do
      money = Philiprehberger::Money.new(1001, :usd)
      shares = money.allocate([0.5, 0.5])
      expect(shares.map(&:cents)).to contain_exactly(500, 501)
      expect(shares.sum(&:cents)).to eq(1001)
    end

    it 'sums to original amount for complex ratios' do
      money = Philiprehberger::Money.new(9999, :usd)
      shares = money.allocate([0.4, 0.35, 0.15, 0.1])
      expect(shares.sum(&:cents)).to eq(9999)
    end
  end
end
