#!/usr/bin/env ruby

INPUT = ''.freeze

class TileSolver
  def initialize(input, line_count)
    @input = input
    @line_count = line_count
    @rows = [@input]
    create_rows
  end

  def create_rows
    (1...@line_count).each { |idx| @rows[idx] = create_row(@rows[idx - 1]) }
  end

  def create_row(input)
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

  def save_tiles_count
    # puts '=' * (@input.size + 4)
    # @rows.each_with_index { |r, i| puts "#{i.to_s.rjust(2)}: #{r}" }
    # puts '=' * (@input.size + 4)
    @rows.map { |r| r.delete('^').size }.inject(0, &:+)
  end
end

INPUT = '.^^^.^.^^^.^.......^^.^^^^.^^^^..^^^^^.^.^^^..^^.^.^^..^.^..^^...^.^^.^^^...^^.^.^^^..^^^^.....^....'.freeze
puts "Test 1: #{TileSolver.new('..^^.', 3).save_tiles_count} (corr: 6)"
puts "Test 2: #{TileSolver.new('.^^.^.^^^^', 10).save_tiles_count} (corr: 38)"
puts "Part 1: #{TileSolver.new(INPUT, 40).save_tiles_count} (corr: 2013)"
puts "Part 2: #{TileSolver.new(INPUT, 400_000).save_tiles_count} (corr: 20006289)"
