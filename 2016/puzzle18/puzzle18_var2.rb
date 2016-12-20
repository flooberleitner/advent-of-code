#!/usr/bin/env ruby

class TileSolver
  def initialize(input, line_count)
    @input = ".#{input}.".tr('.^', '10').to_i(2) # convert to numeric for bit manipulation
    @line_size = input.size + 2 # +2 because of leading/trailing save tile added
    @line_count = line_count
    @rows = [@input]
    @save_tile_count = nil
    dist = @line_size - 3
    @trap_vals_original = [
      0b001 << dist,
      0b100 << dist,
      0b011 << dist,
      0b110 << dist
    ].freeze
  end

  def save_tile_count
    return @save_tile_count if @save_tile_count
    @save_tile_count = 0

    line = @input
    (0...@line_count).each do
      @save_tile_count += count_save_tiles(line)
      line = create_row(line)
    end
    @save_tile_count -= @line_count * 2 # substract the added leading/trailing save tiles
  end

  private def count_save_tiles(line)
    cnt = 0
    @line_size.times do
      cnt += 1 unless (line & 1).zero?
      line >>= 1
    end
    cnt
  end

  private def create_row(input)
    trap_vals = intialize_trap_vals
    mask = 0b111 << (@line_size - 3)
    out = 1 << 1
    (@line_size - 2).times do
      out |= 1 unless trap_vals.any? { |v| (input & mask) == v }
      out <<= 1
      trap_vals.map! { |v| v >> 1 }
      mask >>= 1
    end
    out |= 1
  end

  private def intialize_trap_vals
    # input of size 5 (1432101; padded with 1 at begin/end) will be masked with XXX0000
    # -> we shift the mask by size-1 to the left for starting position
    #    and then start checking for size-1 runs
    @trap_vals_original.dup
  end
end

INPUT = '.^^^.^.^^^.^.......^^.^^^^.^^^^..^^^^^.^.^^^..^^.^.^^..^.^..^^...^.^^.^^^...^^.^.^^^..^^^^.....^....'.freeze
[
  ['Test 1', '..^^.', 3, 6],
  ['Test 2', '.^^.^.^^^^', 10, 38],
  ['Part 1', INPUT, 40, 2013],
  ['Part 2', INPUT, 400_000, 20_006_289]
].each do |p|
  res = TileSolver.new(p[1], p[2]).save_tile_count
  puts "#{p[0]}: #{res}#{res == p[3] ? '' : "(corr: #{p[3]})"}"
end
