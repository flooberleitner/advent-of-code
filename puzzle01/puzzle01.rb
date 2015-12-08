#!/usr/bin/env ruby -w

instructions = ''
File.open('input.txt') do |input|
  instructions = input.read.split(//)
end

data = { way: [0], pos: -1 }
instructions.each_with_index do |instruction, index|
  data[:way] << data[:way].last + 1 if instruction == '('
  data[:way] << data[:way].last - 1 if instruction == ')'

  data[:pos] = index if data[:pos] == -1 && data[:way].last == -1
end

puts "Puzzle01 Pt01: #{data[:way].last}"
puts "Puzzle01 Pt02: #{data[:pos] + 1}"   # because first element has position 1
