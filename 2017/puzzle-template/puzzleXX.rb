#!/usr/bin/env ruby

open(ARGV[0]) do |input|
  # Get and sanitize input
  data = input.readlines.map(&:strip)

  # Process data
  res1 = 0
  res2 = 0

  # Print result
  puts "AOC17-XX/1: #{res1} (Corr: ???)"
  puts "AOC17-XX/2: #{res2} (Corr: ???)"
end
