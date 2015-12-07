#!/usr/bin/env ruby -w

pattern_double_char = /(.).(\1)/
pattern_repeat_double_char = /(..).*(\1)/

good_words = 0
File.open('puzzle05_input.txt') do |input|
  input.each_line do |line|
    next unless pattern_double_char.match(line)
    next unless pattern_repeat_double_char.match(line)
    good_words += 1
  end
end

puts 'Puzzle05 Pt02: Good Words=' + good_words.to_s
