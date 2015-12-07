#!/usr/bin/env ruby -w

instructions = ''
File.open('input.txt') do |input|
  instructions = input.read.split(//)
end

way = [0]
instructions.each_with_object(way) do |instruction, memo|
  memo << memo.last + 1 if instruction == '('
  memo << memo.last - 1 if instruction == ')'
end

puts way.last
