#!/usr/bin/env ruby

class Turtle
  attr_reader :first_dbl_loc, :visits

  def initialize(data)
    @x = 0
    @y = 0
    @dir = 0 # 0: north, 1: east, 2: south, 3: west
    @visits = Hash.new(0)
    @first_dbl_loc = nil

    data.readlines.each do |line|
      line.split(', ').each do |cmd|
        move(rot: cmd[0].downcase.to_sym, dist: cmd[1..-1].to_i)
      end
    end
  end

  def move(rot:, dist:)
    @dir += rot == :l ? -1 : 1
    @dir = 0 if @dir > 3
    @dir = 3 if @dir < 0

    dist.times { make_step }
  end

  def make_step
    case @dir
    when 0
      @y -= 1
    when 1
      @x += 1
    when 2
      @y += 1
    when 3
      @x -= 1
    end

    loc = { x: @x, y: @y }
    @visits[loc] += 1

    @first_dbl_loc = loc if @first_dbl_loc.nil? && @visits[loc] == 2
  end

  def dist_from_zero
    @x.abs + @y.abs
  end

  def dist_from_zero_for_first_dbl_loc
    return 0 unless @first_dbl_loc
    @first_dbl_loc[:x].abs + @first_dbl_loc[:y].abs
  end
end

open('puzzle01_input.txt') do |input|
  turtle = Turtle.new(input)
  puts '2017:Puzzle01'
  puts "Step1: #{turtle.dist_from_zero}"
  puts "Step2: #{turtle.dist_from_zero_for_first_dbl_loc}"
end
