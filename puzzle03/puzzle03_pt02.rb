#!/usr/bin/env ruby -w

class Navigator
  def initialize(x = 0, y = 0)
    @x = x
    @y = y
    @visits = {}
    add_visit
  end

  attr_accessor :visits

  def move(dir = nil)
    case dir
    when '^' then north
    when '>' then east
    when 'v' then south
    when '<' then west
    end
  end

  def north
    @y += 1
    add_visit
  end

  def east
    @x += 1
    add_visit
  end

  def south
    @y -= 1
    add_visit
  end

  def west
    @x -= 1
    add_visit
  end

  def add_visit(x = @x, y = @y)
    # visits are store with a string key of format 'X_Y'
    # corresponding to the coordinates on the 2D-map
    key = "#{x}_#{y}"
    visits = @visits[key] || 0
    @visits[key] = visits + 1
  end

  def houses_with_presents
    @visits.size
  end
end

nav_santa = Navigator.new
nav_robo = Navigator.new
instructions = nil
File.open('puzzle03_input.txt') do |input|
  instructions = input.read.split(//)
end

instructions.each_index { |idx| idx.even? ? nav_santa.move(instructions[idx]) : nav_robo.move(instructions[idx]) }

puts 'Houses with at least one present: ' + nav_santa.visits.merge(nav_robo.visits).size.to_s
