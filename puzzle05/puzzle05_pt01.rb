#!/usr/bin/env ruby -w

module Enumerable
  # MonkeyPatch to have conditions that are better readable
  def missing?(pattern)
    !include?(pattern)
  end
end

at_least_tree_of = %w(a e i o u)
none_of = %w(ab cd pq xy)
pattern_double_char = /(.)(\1)/

good_words = 0
File.open('puzzle05_input.txt') do |input|
  input.each_line do |line|
    next unless pattern_double_char.match(line)
    next unless none_of.reduce(true) { |a, e| a && !line.match(e) }
    next if line.split(//).delete_if { |char| at_least_tree_of.missing?(char) }.size < 3
    good_words += 1
  end
end

puts 'Puzzle05: Good Words=' + good_words.to_s
