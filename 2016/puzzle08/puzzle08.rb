#!/usr/bin/env ruby

if ARGV.size.zero?
  puts 'Please provide path to input file'
  exit 1
end

class Display
  CMD_MAP = {
    /^rect (?<p1>\d+)x(?<p2>\d+)$/ => :draw_rect,
    /^rotate row [xy]=(?<p1>\d+) by (?<p2>\d+)$/ => :rotate_row,
    /^rotate column [xy]=(?<p1>\d+) by (?<p2>\d+)$/ => :rotate_column
  }.freeze

  def initialize(width:, height:)
    @data = Array.new(height) { Array.new(width, 0) }
  end

  def process_commands(commands)
    commands.each { |cmd| process_command(cmd) }
  end

  def process_command(command)
    CMD_MAP.each do |pattern, method|
      command.match(pattern) do |m|
        send(method, m[:p1].to_i, m[:p2].to_i)
        return true
      end
    end
    raise "Unknown command '#{command}'"
  end

  def draw_rect(width, height)
    width.times { |x| height.times { |y| @data[y][x] = 1 } }
  end

  def rotate_column(index, dist)
    @data.map { |row| row[index] }
         .rotate(-dist)
         .each_with_index { |c, i| @data[i][index] = c }
  end

  def rotate_row(index, dist)
    @data[index].rotate!(-dist)
  end

  def pixels_lit
    @data.flatten.inject(0, &:+)
  end

  def print
    @data.each { |ln| puts ln.map { |px| px == 1 ? '##' : '  ' }.join }
  end
end

# test_cmds = [
#   'rect 3x2',
#   'rotate column x=1 by 1',
#   'rotate row y=0 by 4',
#   'rotate column x=1 by 1'
# ]
# test = Display.new(width:7, height: 3)
# test.process_commands(test_cmds)
# puts '=' * 100
# test.print
# puts "Test pixel lit: #{test.pixels_lit}"

step1 = Display.new(width: 50, height: 6)
commands = open(ARGV[0]).readlines.map(&:strip)
step1.process_commands(commands)

step1.print
puts "Puzzle08 Step1: Pixels lit: #{step1.pixels_lit}"
puts 'Puzzle08 Step2: Read the displayprint above ;)'
