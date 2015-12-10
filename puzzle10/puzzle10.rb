#!/usr/bin/env ruby

inputs = {
  test: { string: '1', iter: 5 },
  part1: { string: '1113222113', iter: 40 },
  part2: { string: '1113222113', iter: 50 }
}
what_to_do = :part2

replace_pattern = /(([\d])\2{0,})/

input = inputs[what_to_do]
output = input[:string]
(1..input[:iter]).each do
  output.gsub!(replace_pattern) { |m| "#{m.size}#{m[0]}" }
end

puts "Puzzle01 #{what_to_do}: size=#{output.size}"
