#!/usr/bin/env ruby

raise 'Requires at least Ruby v2.0.0' if RUBY_VERSION[0].to_i < 2

require 'curses'

class Building
  def initialize
    @floor_content = Array.new(4) { Array.new(4, nil) }
    @elevator_pos = 0 # 0: first floor, 1: second floor, ...
    @selected_items = []
  end

  def run
    errors = []
    Curses.init_screen
    begin
      Curses.crmode

      paint(errors: errors)
      loop do |key|
        errors.clear
        key = Curses.getch
        case key
        when 'e'
          puts 'leaving'
          break
        else
          errors << "Key '#{key}' not handled."
        end

        paint(errors: errors)
      end

    ensure
      Curses.close_screen
    end
  end

  private def paint(errors: nil)
    Curses.clear
    # Curses.setpos((lines - 5) / 2, (cols - 10) / 2)
    @floor_content.reverse.each_with_index do |_floor, floor_idx|
      Curses.addstr "Floor #{4 - floor_idx} |#{@elevator_pos == floor_idx ? 'E'.center(3) : ''.center(3)}|\n"
    end
    unless errors.empty?
      Curses.addstr "============================\n"
      Curses.addstr "Errors:\n"
      errors.each do |err|
        Curses.addstr "   #{err}\n"
      end
    end

    Curses.refresh
  end
end

building = Building.new

building.run
