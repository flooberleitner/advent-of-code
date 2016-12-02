#!/usr/bin/env ruby

class LoginHandler
  COL = 0
  ROW = 1

  attr_reader :code

  def initialize(data)
    @code = ''
    @finger = [1, 1] # [column, row], [1, 1] is key '5'
    data.readlines.each do |line|
      press(line)
    end
  end

  def press(cmd)
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
    @finger[COL] -= 1 unless @finger[COL].zero?
  end

  def step_finger_right
    @finger[COL] += 1 unless @finger[COL] == 2
  end

  def step_finger_up
    @finger[ROW] -= 1 unless @finger[ROW].zero?
  end

  def step_finger_down
    @finger[ROW] += 1 unless @finger[ROW] == 2
  end

  def press_finger
    @code << ((@finger[1] * 3) + @finger[0] + 1).to_s
  end

  def value_under_finger(col: nil, row: nil)
  end
end

open('puzzle02_input.txt') do |file|
  login = LoginHandler.new(file)
  puts login.code
end
