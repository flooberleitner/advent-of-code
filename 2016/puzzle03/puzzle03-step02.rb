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

triangles = []
open(ARGV[0]) do |file|
  group = []
  file.readlines.each do |line|
    tri = line.strip.split(' ').map(&:to_i)
    group << tri if group.size < 3

    if group.size == 3
      triangles.concat group.transpose
      group = []
    end
  end
end

valid_tris = 0
triangles.each do |triangle|
  valid_tris += 1 if tri_valid?(triangle)
end

puts "Puzzle03 Step2: #{valid_tris}/#{triangles.size}"
