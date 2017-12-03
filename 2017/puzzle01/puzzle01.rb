#!/usr/bin/env ruby

class String
  def digit_sum(compare_offset: 1)
    digits = split('')
    digits_compare = digits.rotate(compare_offset)
    digits.zip(digits_compare).map do |candidates|
      candidates.first == candidates.last ? candidates.first.to_i : nil
    end.compact.sum
  end
end

open(ARGV[0]) do |input|
  # Process input
  data = input.readlines.map(&:strip)
  sums01 = data.map(&:digit_sum)
  sums02 = data.map { |num| num.digit_sum(compare_offset: num.size / 2) }

  # Print result
  puts "AOC17-01/1: #{sums01.join(',')}"
  puts "AOC17-01/2: #{sums02.join(',')}"
end
