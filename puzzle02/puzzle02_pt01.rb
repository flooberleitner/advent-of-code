#!/usr/bin/env ruby -w

class Box
  def initialize(x, y, z)
    @x = x.to_i
    @y = y.to_i
    @z = z.to_i
  end

  def paper_needed
    sides = [@x * @y, @x * @z, @y * @z]
    sides.reduce(0) { |a, e| a + 2 * e } + sides.min
  end
end

packets = []
File.open('puzzle02_input.txt') do |input|
  input.each do |line|
    packets << Box.new($1, $2, $3) if /(\d+)x(\d+)x(\d+)/.match(line)
  end
end

# puts packets.inject(:paper_needed)
puts packets.reduce(0) { |a, e| a + e.paper_needed }
