# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Money rounding modes' do
  describe '.from_amount with rounding:' do
    context ':half_even (default)' do
      it 'rounds 0.025 to 2 cents' do
        money = Philiprehberger::Money.from_amount(0.025, :usd)
        expect(money.cents).to eq(2)
      end

      it 'rounds 0.035 to 4 cents' do
        money = Philiprehberger::Money.from_amount(0.035, :usd)
        expect(money.cents).to eq(4)
      end

      it 'stores the rounding mode' do
        money = Philiprehberger::Money.from_amount(1.00, :usd)
        expect(money.rounding_mode).to eq(:half_even)
      end
    end

    context ':half_up' do
      it 'rounds 0.025 to 3 cents (standard rounding)' do
        money = Philiprehberger::Money.from_amount(0.025, :usd, rounding: :half_up)
        expect(money.cents).to eq(3)
      end

      it 'rounds 0.035 to 4 cents' do
        money = Philiprehberger::Money.from_amount(0.035, :usd, rounding: :half_up)
        expect(money.cents).to eq(4)
      end

      it 'stores the rounding mode' do
        money = Philiprehberger::Money.from_amount(1.00, :usd, rounding: :half_up)
        expect(money.rounding_mode).to eq(:half_up)
      end
    end

    context ':ceil' do
      it 'rounds 0.021 up to 3 cents' do
        money = Philiprehberger::Money.from_amount(0.021, :usd, rounding: :ceil)
        expect(money.cents).to eq(3)
      end

      it 'does not round exact amounts' do
        money = Philiprehberger::Money.from_amount(1.50, :usd, rounding: :ceil)
        expect(money.cents).to eq(150)
      end

      it 'stores the rounding mode' do
        money = Philiprehberger::Money.from_amount(1.00, :usd, rounding: :ceil)
        expect(money.rounding_mode).to eq(:ceil)
      end
    end

    context ':floor' do
      it 'rounds 0.029 down to 2 cents' do
        money = Philiprehberger::Money.from_amount(0.029, :usd, rounding: :floor)
        expect(money.cents).to eq(2)
      end

      it 'does not round exact amounts' do
        money = Philiprehberger::Money.from_amount(1.50, :usd, rounding: :floor)
        expect(money.cents).to eq(150)
      end

      it 'stores the rounding mode' do
        money = Philiprehberger::Money.from_amount(1.00, :usd, rounding: :floor)
        expect(money.rounding_mode).to eq(:floor)
      end
    end

    context 'invalid rounding mode' do
      it 'raises ArgumentError' do
        expect do
          Philiprehberger::Money.from_amount(1.00, :usd, rounding: :invalid)
        end.to raise_error(ArgumentError, /Unknown rounding mode/)
      end
    end

    context 'rounding mode propagates to arithmetic' do
      it 'uses half_up in multiplication' do
        money = Philiprehberger::Money.from_amount(0.05, :usd, rounding: :half_up)
        result = money * 0.5
        # 5 * 0.5 = 2.5 -> half_up rounds to 3
        expect(result.cents).to eq(3)
      end

      it 'uses half_even in multiplication (default)' do
        money = Philiprehberger::Money.from_amount(0.05, :usd)
        result = money * 0.5
        # 5 * 0.5 = 2.5 -> half_even rounds to 2
        expect(result.cents).to eq(2)
      end

      it 'uses ceil in division' do
        money = Philiprehberger::Money.from_amount(0.10, :usd, rounding: :ceil)
        result = money / 3
        # 10 / 3 = 3.333... -> ceil rounds to 4
        expect(result.cents).to eq(4)
      end

      it 'uses floor in division' do
        money = Philiprehberger::Money.from_amount(0.10, :usd, rounding: :floor)
        result = money / 3
        # 10 / 3 = 3.333... -> floor rounds to 3
        expect(result.cents).to eq(3)
      end
    end
  end
end
