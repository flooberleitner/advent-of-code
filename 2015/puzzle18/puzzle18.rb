#!/usr/bin/env ruby

class GameOfLife
  def initialize(width, height, live_on, create, initial_configuration = '', corners_stuck = false)
    @height = height
    @width = width
    @board = Array.new(height * width, 0)
    @live_on = live_on
    @create = create
    @corners_stuck = corners_stuck

    return self if initial_configuration.empty?
    lines = File.readlines(initial_configuration)
    fail 'Not enough lines in initial config' if lines.size < @height
    lines.each_with_index do |line, y|
      chars = line.split(//)
      fail 'line has not enough chars' if chars.size < @width
      chars.each_with_index { |chr, x| turn_on(x, y) if chr == '#' }
    end

    turn_corners_on if corners_stuck
  end
  attr_reader :live_on, :live, :create, :width, :height

  def step
    old_board = @board.clone
    (0...@height).each do |y|
      (0...@width).each do |x|
        if off?(x, y, old_board)
          turn_on(x, y) if @create.include?(neighbor_sum(x, y, old_board))
        else
          turn_off(x, y) unless @live_on.include?(neighbor_sum(x, y, old_board))
        end
      end
    end
    turn_corners_on if @corners_stuck
  end

  def lights_on
    @board.reduce(:+)
  end

  def inspect
    (0...@height).map { |y| @board[offset(0, y)..offset(@width - 1, y)].join }.join("\n")
  end

  private

  def neighbor_sum(x, y, board = @board)
    x_vals = case x
             when 0 then (0..1).to_a
             when @width - 1 then ((@width - 2)...@width).to_a
             else
               ((x - 1)..(x + 1)).to_a
             end
    y_vals = case y
             when 0 then (0..1).to_a
             when @height - 1 then ((@height - 2)...@height).to_a
             else
               ((y - 1)..(y + 1)).to_a
             end

    # sum up all cells
    sum = 0
    x_vals.each do |sum_x|
      y_vals.each do |sum_y|
        sum += board[offset(sum_x, sum_y)]
      end
    end

    # substract cell given by x,y so just the neigbors sum remains
    sum -= board[offset(x, y)]

    sum
  end

  def turn_on(x, y, board = @board)
    board[offset(x, y)] = 1
  end

  def on?(x, y, board = @board)
    board[offset(x, y)] == 1
  end

  def turn_off(x, y, board = @board)
    board[offset(x, y)] = 0
  end

  def off?(x, y, board = @board)
    board[offset(x, y)] == 0
  end

  def offset(x, y)
    y * @width + x
  end

  def turn_corners_on
    turn_on(0, 0)
    turn_on(@width - 1, @height - 1)
    turn_on(@width - 1, 0)
    turn_on(0, @height - 1)
  end
end

gol_test = GameOfLife.new(6, 6, [2, 3], [3], 'puzzle18_input_test.txt')
gol = GameOfLife.new(100, 100, [2, 3], [3], 'puzzle18_input.txt')
gol_stuck = GameOfLife.new(100, 100, [2, 3], [3], 'puzzle18_input.txt', true)

puts gol_test.lights_on
4.times { gol_test.step }
puts gol_test.lights_on

100.times { gol.step; gol_stuck.step }
puts "Puzzle18: Part01: total_light_on=#{gol.lights_on}"
puts "Puzzle18: Part02: total_light_on=#{gol_stuck.lights_on}"
