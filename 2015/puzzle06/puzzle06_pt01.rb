#!/usr/bin/env ruby -w

require 'trollop'

opts = Trollop.options do
  version 'AoC:Puzzle06, (c) Florian Oberleitner (florian.oberleitner@gmail.com)'
  opt :input, 'Path to input data', type: String
end
Trollop.die :input, 'required' unless opts[:input]
Trollop.die :input, 'does not exist' unless File.exist?(opts[:input])

instruction_pattern = /^(?<cmd>turn|toggle)? (?<sub>on|off)? ?(?<from_x>\d{1,3}),(?<from_y>\d{1,3}) through (?<to_x>\d{1,3}),(?<to_y>\d{1,3})$/

class Lights
  def initialize(width, heigth)
    @lights = {}
    (0...width).each do |x|
      @lights[x] = {}
      (0...heigth).each do |y|
        @lights[x][y] = 0
      end
    end
  end

  def render(cmd, sub, from_x, from_y, to_x, to_y)
    (from_y..to_y).each do |y|
      (from_x..to_x).each do |x|
        render_light(x, y, cmd, sub)
      end
    end
  end

  def render_light(x, y, cmd, sub)
    case cmd
    when :turn
      turn(x, y, sub)
    when :toggle
      toggle(x, y)
    else
      fail ArgumentError, "Unknown command '#{cmd}'"
    end
  end

  def turn(x, y, sub)
    case sub
    when :on
      @lights[x][y] = 1
    when :off
      @lights[x][y] = 0
    else
      fail ArgumentError, "Unknonw sub-command '#{sub}'"
    end
  end

  def toggle(x, y)
    @lights[x][y] = 1 - @lights[x][y]
  end

  def turned_on_nb
    @lights.map { |e| e[1].values }.flatten.reduce(:+)
  end

  def inspect
    @lights.inspect
  end

  def to_s
    inspect
  end
end

puts 'Reading instructions...'
instructions = []
File.open(opts[:input]) do |input|
  input.each_line do |line|
    instructions << Regexp.last_match if instruction_pattern.match(line)
  end
end

print 'Rendering instructions'
lights = Lights.new(1000, 1000)
instructions.each_index do |index|
  print '.' if index % 10 == 0
  print index.to_s if index % 50 == 0

  inst = instructions[index]
  lights.render(inst[:cmd].to_sym, inst[:sub] ? inst[:sub].to_sym : nil, inst[:from_x].to_i, inst[:from_y].to_i, inst[:to_x].to_i, inst[:to_y].to_i)
end
puts ''

puts "Puzzle06 Pt1: #{lights.turned_on_nb} lights turned on"
