#!/usr/bin/env ruby

require_relative '../lib/node_traversal'

class BuildingState
  TOP_FLOOR = 3
  def initialize(floor_setup = nil)
    @floors = floor_setup
    @elev_pos = 0
    @moves = 0
  end
  attr_reader :floors, :elev_pos, :moves

  ##
  # All items in the the top most floor is considered finished.
  # -> all remaining floors must be empty
  def finished?
    @floors[0..2].map(&:size).inject(0, &:+).zero?
  end

  ##
  # Return possible new states as Array.
  # If there are none, an empty Array is returned
  def possible_new_states
    states = []
    moves = possible_moves
    unless @elev_pos == TOP_FLOOR
      moves.each_with_object(states) do |items, memo|
        memo << dup.move_elev(items: items, dir: :up)
      end
    end

    unless @elev_pos.zero?
      moves.each_with_object(states) do |items, memo|
        memo << dup.move_elev(items: items, dir: :down)
      end
    end
    states.delete_if(&:invalid?).to_a
  end

  def move_elev(items:, dir:)
    new_elev_pos = @elev_pos + (dir == :up ? 1 : -1)
    new_elev_pos = 0 if new_elev_pos < 0
    new_elev_pos = TOP_FLOOR if new_elev_pos > TOP_FLOOR

    @floors[@elev_pos].delete_if { |item| items.include?(item) }
    @floors[new_elev_pos].concat(items)
    @elev_pos = new_elev_pos
    @moves += 1
    self
  end

  def possible_moves
    moves = @floors[@elev_pos].permutation(1)
                              .to_a
                              .concat @floors[@elev_pos].permutation(2).to_a
    moves.map(&:sort).uniq
  end

  def valid?
    @floors.each.map { |floor| valid_floor?(floor) }.all?
  end

  def invalid?
    !valid?
  end

  def valid_floor?(floor)
    return true if floor.empty?
    transposed = floor.transpose.map(&:uniq)
    return true if transposed[0] == [:gen]
    return true if transposed[0] == [:chip]

    floor.each do |item|
      return false if item[0] == :chip && !floor.include?([:gen, item[1]])
    end
    true
  end

  def eql?(other)
    floors_eql = @floors.each_with_object([]) do |floor, memo|
      idx = @floors.index(floor)
      memo << (floor.sort == other.floors[idx].sort)
    end
    if floors_eql.all? && @elev_pos == other.elev_pos
      # puts "=== Equal ==="
      # puts "#{inspect}"
      # puts "#{other.inspect}"
      return true 
    end

    # puts "=== Not Equal ==="
    # puts "#{inspect}"
    # puts "#{other.inspect}"

    false
  end

  def ==(other)
    eql?(other)
  end

  def initialize_copy(source)
    @floors = source.floors.map { |l| l.map(&:dup) }
    @elev_pos = source.elev_pos
    @moves = source.moves
  end
end


# TODO: Write traversal function
def solve_part1(start)
  result = nil
  node_traverser = NodeTraversal.new do |ns|
    ns.on_next_nodes(&:possible_new_states)
    ns.on_check_node { |node, q, v| puts "Checking node: #{q.size}, #{v.size}"; :break if node.finished? }
    # ns.on_check_node { |node, q, v| :break if node.finished? }
    ns.on_finished { |last_node, _visited| result = last_node }
  end
  node_traverser.run(start)
  result
end

test_building = BuildingState.new(
  [
    [
      [:chip, :hydrogen],
      [:chip, :lithium]
    ],
    [
      [:gen, :hydrogen]
    ],
    [
      [:gen, :lithium]
    ],
    []
  ]
)
# test_final = solve_part1(test_building)
# puts "Test: #{test_final.moves} (corr: 11)"

part1_building = BuildingState.new(
  [
    [
      [:chip, :promethium],
      [:gen, :promethium]
    ],
    [
      [:gen, :cobalt],
      [:gen, :curium],
      [:gen, :ruthenium],
      [:gen, :plutonium]
    ],
    [
      [:chip, :cobalt],
      [:chip, :curium],
      [:chip, :ruthenium],
      [:chip, :plutonium]
    ],
    []
  ]
)
part1_final = solve_part1(part1_building)
puts "Part 1: #{part1_final.step_count} (corr: ??)"

# TODO: SPEED UP IMPLEMENTATION
# - store floor status via bit stuffing - should be faster than arrays
# - more intelligent pruning

# visited_states = [initial]
# puts initial.inspect
# puts 'Possible Moves', initial.possible_moves.inspect
# puts 'Possible Up Moves'
# initial.possible_moves.each { |m| puts m.inspect }
# puts 'Possible States'
# initial.possible_new_states.each { |s| puts s.inspect }
# puts "Part 1: #{part1_final ? part1_final.moves : 'No Solution'} (corr: 82)"
# puts "Part 1: #{part1_final.moves} (corr: ??)"
