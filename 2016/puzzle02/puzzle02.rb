#!/usr/bin/env ruby

class LoginHandler
  COL = 0
  ROW = 1

  attr_reader :code

  def initialize(data:, pad:, finger_at:)
    @pad = pad
    @code = ''
    @finger = finger_at # [column, row]
    @col_max = @pad[0].size - 1
    @row_max = @pad.size - 1

    data.readlines.each do |line|
      move_and_press(line)
    end
  end

  def move_and_press(cmd)
    move_finger(cmd)
    press_finger
  end

  def move_finger(cmd)
    cmd.each_char { |c| step_finger(c) }
  end

  def step_finger(dir)
    case dir
    when 'L' then step_finger_left
    when 'R' then step_finger_right
    when 'U' then step_finger_up
    when 'D' then step_finger_down
    end
  end

  def step_finger_left
    return if @finger[COL].zero? ||
              value_at_finger(col: @finger[COL] - 1) == ' '
    @finger[COL] -= 1
  end

  def step_finger_right
    return if @finger[COL] == @col_max ||
              value_at_finger(col: @finger[COL] + 1) == ' '
    @finger[COL] += 1
  end

  def step_finger_up
    return if @finger[ROW].zero? ||
              value_at_finger(row: @finger[ROW] - 1) == ' '
    @finger[ROW] -= 1
  end

  def step_finger_down
    return if @finger[ROW] == @row_max ||
              value_at_finger(row: @finger[ROW] + 1) == ' '
    @finger[ROW] += 1
  end

  def press_finger
    @code << value_at_finger
  end

  def value_at_finger(col: nil, row: nil)
    col = col ? col : @finger[COL]
    row = row ? row : @finger[ROW]
    @pad[row][col]
  end
end

open('puzzle02_input.txt') do |file|
  login1 = LoginHandler.new(
    data: file,
    pad: [
      '123 ',
      '456 ',
      '789 '
    ],
    finger_at: [1, 1]
  )
  puts "Login Step1: #{login1.code}"

  file.rewind
  login2 = LoginHandler.new(
    data: file,
    pad: [
      '  1  ',
      ' 234 ',
      '56789',
      ' ABC ',
      '  D  '
    ],
    finger_at: [2, 2]
  )
  puts "Login Step2: #{login2.code}"
end
