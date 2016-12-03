#!/usr/bin/env ruby

if ARGV.size.zero?
  puts 'Please provide path to input file'
  exit 1
end

def tri_valid?(tri)
  if (tri[0] + tri[1]) > tri[2] &&
     (tri[0] + tri[2]) > tri[1] &&
     (tri[1] + tri[2]) > tri[0]
    return true
  end
  false
end

valid_tris = 0
total = 0
open(ARGV[0]) do |file|
  file.readlines.each do |line|
    total += 1
    valid_tris += 1 if tri_valid?(line.strip.split(' ').map(&:to_i))
  end
end

puts "Puzzle03 Step1: #{valid_tris}/#{total}"
