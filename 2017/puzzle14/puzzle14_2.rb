#!/usr/bin/env ruby

require_relative '../../lib/knot_hash'

class IdGenerator
  def initialize(start_id: 0)
    @start = start_id
    reset
  end
  attr_reader :current

  def reset
    @current = @start
  end

  def next
    @current += 1
  end
end

class Cell
  @neighbor_dirs = [:n, :e, :s, :w]
  @opp_neighbor_dir = {
    n: :s,
    s: :n,
    e: :w,
    w: :e
  }

  def self.valid_neigbor_dirs
    @neighbor_dirs
  end

  def self.opp_neighbor_dir(dir)
    @opp_neighbor_dir[dir]
  end

  def initialize(value:, id_generator:)
    @value = value
    @group = nil
    @neighbors = {}
    @group_id_gen = id_generator
  end

  def set_neighbor(dir:, neighbor:, reverse: true)
    raise "dir '#{dir}' not supported by cell" unless Cell.valid_neigbor_dirs.include? dir
    @neighbors[dir] = neighbor
    return unless reverse
    neighbor.set_neighbor(
      dir: Cell.opp_neighbor_dir(dir),
      neighbor: self,
      reverse: false
    )
  end

  def chisel_group(group_id: nil)
    return if @group || @value.zero?
    @group = group_id || @group_id_gen.next
    @neighbors.values.each { |cell| cell.chisel_group(group_id: @group) }
    self
  end
end

def generate_board(key, id_generator:)
  (0..127).map do |line_num|
    binary = "#{key}-#{line_num}".knot_hash.to_i(16).to_s(2)
    binary = '0' * (128 - binary.size) + binary if binary.size < 128
    binary.chars.map { |val| Cell.new(value: val.to_i, id_generator: id_generator) }
  end
end

def assign_neighbors(board)
  board.each_with_index do |row, row_idx|
    row.each_with_index do |cell, cell_idx|
      cell.set_neighbor(dir: :n, neighbor: board[row_idx - 1][cell_idx]) if row_idx > 0
      cell.set_neighbor(dir: :s, neighbor: board[row_idx + 1][cell_idx]) if row_idx < (board.size - 1)
      cell.set_neighbor(dir: :w, neighbor: row[cell_idx - 1]) if cell_idx > 0
      cell.set_neighbor(dir: :e, neighbor: row[cell_idx + 1]) if cell_idx < (row.size - 1)
    end
  end
  board
end

def chisel_groups(board)
  board.map { |row| row.map(&:chisel_group) }
end

# Declare the number of the AOC17 puzzle
PUZZLE = 14

# Declare all runs to be done for this puzzle
{
  test: {
    input: 'flqrgnkx',
    target: 1242
  },
  puzzle02: {
    skip: false,
    input: 'xlqgujun',
    target: 1089
  }
}.each do |run_name, run_pars|
  # skip run?
  if run_pars[:skip]
    puts "Skipped '#{run_name}'"
    next
  end

  # open input data and process it
  input = if File.exist?(run_pars[:input])
            open(run_pars[:input]) do |file|
              # Read all input lines and sanitize
              file.readlines.map(&:strip)
            end
          else
            # use input parameter directly
            run_pars[:input]
          end

  # Process data
  id_generator = IdGenerator.new
  board = assign_neighbors(generate_board(input, id_generator: id_generator))
  chisel_groups(board)
  res = id_generator.current

  # Print result
  success_msg1 = res == run_pars[:target] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name} #{success_msg1}: #{res} (Target: #{run_pars[:target]})"
  puts '=' * 50
end
