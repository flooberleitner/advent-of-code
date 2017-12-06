#!/usr/bin/env ruby

class Array
  def min_max_diff
    max - min
  end

  def even_divider
    combination(2).map do |comb|
      (comb.max % comb.min).zero? ? comb.max / comb.min : nil
    end.compact.first
  end
end

open(ARGV[0]) do |input|
  # Get and sanitize input
  data = input.readlines.map(&:strip).map { |num| num.split(/\W+/).map(&:to_i) }

  # Process data
  checksum1 = data.map(&:min_max_diff).sum
  checksum2 = data.map(&:even_divider).sum

  # Print result
  puts "AOC17-02/1: #{checksum1} (Corr: 37923)"
  puts "AOC17-02/2: #{checksum2} (Corr: 263)"
end
