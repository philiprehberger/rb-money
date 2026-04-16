# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Money do
  describe '#tax_breakdown' do
    let(:net) { described_class.new(10_000, :usd) }

    it 'returns a hash with net, tax, and gross keys' do
      result = net.tax_breakdown(0.2)
      expect(result).to have_key(:net)
      expect(result).to have_key(:tax)
      expect(result).to have_key(:gross)
    end

    it 'calculates 20% tax correctly' do
      result = net.tax_breakdown(0.2)
      expect(result[:net].cents).to eq(10_000)
      expect(result[:tax].cents).to eq(2000)
      expect(result[:gross].cents).to eq(12_000)
    end

    it 'calculates 10% tax correctly' do
      result = net.tax_breakdown(0.1)
      expect(result[:tax].cents).to eq(1000)
      expect(result[:gross].cents).to eq(11_000)
    end

    it 'calculates 0% tax correctly' do
      result = net.tax_breakdown(0)
      expect(result[:tax].cents).to eq(0)
      expect(result[:gross].cents).to eq(10_000)
    end

    it 'uses banker rounding for fractional tax amounts' do
      money = described_class.new(1001, :usd)
      result = money.tax_breakdown(0.1)
      expect(result[:tax].cents).to eq(100)
      expect(result[:gross].cents).to eq(1101)
    end

    it 'rounds half-even for exact halves' do
      money = described_class.new(5, :usd)
      result = money.tax_breakdown(0.5)
      expect(result[:tax].cents).to eq(2)
    end

    it 'preserves currency on all returned Money objects' do
      result = described_class.new(1000, :gbp).tax_breakdown(0.2)
      expect(result[:net].currency.code).to eq(:gbp)
      expect(result[:tax].currency.code).to eq(:gbp)
      expect(result[:gross].currency.code).to eq(:gbp)
    end

    it 'returns the original object as net' do
      result = net.tax_breakdown(0.2)
      expect(result[:net]).to equal(net)
    end

    it 'raises ArgumentError for negative rate' do
      expect { net.tax_breakdown(-0.1) }.to raise_error(ArgumentError, /non-negative/)
    end

    it 'raises ArgumentError for non-numeric rate' do
      expect { net.tax_breakdown('abc') }.to raise_error(ArgumentError)
    end
  end
end
