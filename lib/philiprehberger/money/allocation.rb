# frozen_string_literal: true

module Philiprehberger
  class Money
    # Fair allocation of money across ratios using the largest remainder method
    module Allocation
      # Split money by ratios, distributing remainder cents fairly
      #
      # Uses the largest remainder method: calculate exact shares, floor each,
      # then distribute remaining cents to shares with the largest fractional parts.
      #
      # @param ratios [Array<Numeric>] the ratios to split by (e.g. [0.5, 0.3, 0.2])
      # @return [Array<Money>] array of Money objects that sum to the original amount
      def allocate(ratios)
        total_ratio = ratios.sum(BigDecimal('0'))
        exact_shares = ratios.map { |r| BigDecimal(cents.to_s) * BigDecimal(r.to_s) / total_ratio }
        floored = exact_shares.map { |s| s.floor.to_i }
        remainder = cents - floored.sum

        # Distribute remaining cents to shares with the largest fractional parts
        fractional_parts = exact_shares.each_with_index.map { |s, i| [s - s.floor, i] }
        fractional_parts.sort_by! { |frac, _i| -frac }

        remainder.abs.times do |n|
          idx = fractional_parts[n][1]
          floored[idx] += remainder.positive? ? 1 : -1
        end

        floored.map { |c| self.class.new(c, currency.code) }
      end
    end
  end
end
