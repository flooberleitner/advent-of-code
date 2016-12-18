#!/usr/bin/env ruby

class TileSolver
  def initialize(input, line_count)
    @input = input
    @line_count = line_count
    @rows = [@input]
    @save_tile_count = nil
  end

  def save_tiles_count
    return @save_tile_count if @save_tile_count
    @save_tile_count = 0

    line = @input
    (0...@line_count).each do
      @save_tile_count += count_save_tiles(line)
      line = create_row(line)
    end
    @save_tile_count
  end

  private def count_save_tiles(line)
    line.delete('^').size
  end

  private def create_row(input)
    tmp = ".#{input}."
    out = ''
    (1...(tmp.size - 1)).each do |idx|
      out << case tmp[(idx - 1)..(idx + 1)]
             when '^^.' then '^'
             when '.^^' then '^'
             when '^..' then '^'
             when '..^' then '^'
             else
               '.'
             end
    end
    out
  end
end

INPUT = '.^^^.^.^^^.^.......^^.^^^^.^^^^..^^^^^.^.^^^..^^.^.^^..^.^..^^...^.^^.^^^...^^.^.^^^..^^^^.....^....'.freeze
[
  ['Test 1', '..^^.', 3, 6],
  ['Test 2', '.^^.^.^^^^', 10, 38],
  ['Part 1', INPUT, 40, 2013],
  ['Part 2', INPUT, 400_000, 20_006_289],
].each do |p|
  res = TileSolver.new(p[1], p[2]).save_tiles_count
  puts "#{p[0]}: #{res}#{res == p[3] ? '' : "(corr: #{p[3]})"}"
end
