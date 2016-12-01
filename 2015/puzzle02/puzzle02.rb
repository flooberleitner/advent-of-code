#!/usr/bin/env ruby -w

class Box
  def initialize(x, y, z)
    @x = x.to_i
    @y = y.to_i
    @z = z.to_i
    @areas = [@x * @y, @x * @z, @y * @z]
  end

  def paper_needed
    @areas.reduce(0) { |a, e| a + 2 * e } + @areas.min
  end

  ##
  # ribbon needed is smallest circumference + the volume of the box
  def ribbon_needed
    sides = [@x, @y, @z]
    smallest_sides = sides.clone
    smallest_sides.delete(sides.max)
    # re-add max in case the max occured multiple times
    smallest_sides << sides.max while smallest_sides.size < 2

    smallest_sides.reduce(0) { |a, e| a + 2 * e } + volume
  end

  def volume
    @x * @y * @z
  end
end

packets = []
File.open('puzzle02_input.txt') do |input|
  input.each do |line|
    packets << Box.new($1, $2, $3) if /(\d+)x(\d+)x(\d+)/.match(line)
  end
end

puts "Puzzle02 Pt01: Paper needed: #{packets.map(&:paper_needed).reduce(:+)}"
puts "Puzzle02 Pt02: Ribbon needed: #{packets.map(&:ribbon_needed).reduce(:+)}"
