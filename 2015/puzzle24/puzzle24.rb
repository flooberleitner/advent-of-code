#!/usr/bin/env ruby

if ARGV.size.zero?
  puts 'Please provide path to input file'
  exit 1
end

packages = open(ARGV[0]).readlines.map(&:strip).map(&:to_i)
puts packages.inspect

# check all permutations of possible combinations
puts packages.permutation(2).map(&:sort).inspect

