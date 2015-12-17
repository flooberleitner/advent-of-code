#!/usr/bin/env ruby

containers = [
  50, 44, 11, 49, 42, 46, 18, 32, 26, 40,
  21, 7, 18, 43, 10, 47, 36, 24, 22, 40
].sort

# Limit search scope to max amount of containers needed
# This speeds up the search through all container combinations
combination_limit = 0
containers.each_with_object([]) do |container, memo|
  combination_limit += 1
  memo << container
  break if memo.reduce(:+) >= 150
end

possibilities = (2..combination_limit).reduce([]) do |memo, combo_size|
  memo.concat(containers.combination(combo_size).select do |combo|
    combo.reduce(:+) == 150
  end)
end

puts "Puzzle17 Part1: #{possibilities.size} possibilities"

min_size = possibilities.map(&:size).min
cnt = possibilities.count { |p| p.size == min_size }
puts "Puzzle17 Part2: #{cnt} possibilities of size #{min_size}"
