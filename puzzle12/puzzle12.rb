#!/usr/bin/env ruby

require 'trollop'
require 'json'

opts = Trollop.options do
  version 'AoC:Puzzle08, (c) Florian Oberleitner (florian.oberleitner@gmail.com)'
  opt :input, 'Path to input data', type: String
end
Trollop.die :input, 'required' unless opts[:input]
Trollop.die :input, 'does not exists' unless File.exist?(opts[:input])

#########################################

class String
  def aoc_sum
    scan(/-?\d+/).map(&:to_i).reduce(:+) || 0
  end
end

class Array
  def aoc_sum
    map(&:aoc_sum).reduce(:+)
  end
end

class Hash
  def aoc_sum
    return 0 if values.include?('red')
    values.aoc_sum
  end
end

class Fixnum
  def aoc_sum
    self
  end
end

lines = File.readlines(opts[:input])

puts "Puzzle12: Pt01: #{lines[0].aoc_sum}"

data = JSON.parse(lines[0])
puts "Puzzle12: Pt02: #{data.aoc_sum}"
