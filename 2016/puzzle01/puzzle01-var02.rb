#!/usr/bin/env ruby

class Turtle
  attr_reader :first_dbl_loc, :visits

  def initialize(data)
    # Use a direction vector seen at
    # https://www.reddit.com/r/adventofcode/comments/5fw7ow/my_python_answers_for_day1_spoilers/
    @v = [0, 1] # [0, 1]: north, [1, 0]: east, [0, -1]: south, [-1, 0]: west
    @x = 0
    @y = 0
    @visits = Hash.new(0)
    @first_dbl_loc = nil

    data.readlines.each do |line|
      line.split(', ').each do |cmd|
        move(rot: cmd[0].downcase.to_sym, dist: cmd[1..-1].to_i)
      end
    end
  end

  def move(rot:, dist:)
    rotate(rot: rot)
    dist.times { make_step }
  end

  def rotate(rot:)
    rot == :l ? rotate_left : rotate_right
  end

  def rotate_left
    @v = [-@v[1], @v[0]]
  end

  def rotate_right
    @v = [@v[1], -@v[0]]
  end

  def make_step
    @x += @v[0] * 1
    @y += @v[1] * 1

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
