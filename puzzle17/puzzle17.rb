#!/usr/bin/env ruby

containers = [50, 44, 11, 49, 42, 46, 18, 32, 26, 40, 21, 7, 18, 43, 10, 47, 36, 24, 22, 40]

combinations = (2..(containers.size / 2).ceil).each_with_object([]) do |cnt, memo|
  containers.combination(cnt).each { |combo| memo << combo }
end

possibilities = combinations.reject { |p| p.reduce(:+) != 150 }
puts "Puzzle17 Part1: #{possibilities.size} possibilities"

min_size = possibilities.map(&:size).min
puts "Puzzle17 Part2: #{possibilities.count { |p| p.size == min_size }} possibilities of size #{min_size}"
