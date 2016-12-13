#!/usr/bin/env ruby

require_relative '../lib/node_traversal'

class Node
  def initialize(odfn:, x:, y:, step_count: 0)
    @odfn = odfn # office designers favorite number
    @x = x
    @y = y
    @step_count = step_count
    @prng = Random.new
  end
  attr_reader :x, :y, :step_count

  def floor?
    return false unless @x >= 0 && @y >= 0
    num = ((@x + 3) * @x) + (2 * @x * @y) + ((@y + 1) * @y) + @odfn
    num.to_s(2).split('').map(&:to_i).inject(0, &:+).even?
  end

  def wall?
    !floor?
  end

  def neighbors
    [
      Node.new(odfn: @odfn, x: @x + 1, y: @y, step_count: step_count + 1),
      Node.new(odfn: @odfn, x: @x - 1, y: @y, step_count: step_count + 1),
      Node.new(odfn: @odfn, x: @x, y: @y + 1, step_count: step_count + 1),
      Node.new(odfn: @odfn, x: @x, y: @y - 1, step_count: step_count + 1)
    ].delete_if(&:wall?)
  end

  def eql?(other)
    @x == other.x && @y == other.y
  end

  def ==(other)
    eql?(other)
  end
end

def solve_part1(start:, target:)
  result = nil
  node_searcher = NodeTraversal.new do |ns|
    ns.on_next_nodes(&:neighbors)
    ns.on_check_node { |node| :break if node == target }
    ns.on_finished { |last_node, _visited| result = last_node }
  end
  node_searcher.run(start)
  result
end

def solve_part2(start:, max_steps:)
  result = nil
  node_searcher = NodeTraversal.new do |ns|
    ns.on_next_nodes(&:neighbors)
    ns.on_check_node { |node| :next if node.step_count == max_steps }
    ns.on_finished { |_last_node, visited| result = visited.size }
  end
  node_searcher.run(start)
  result
end

test_final = solve_part1(
  start: Node.new(odfn: 10, x: 1, y: 1),
  target: Node.new(odfn: 10, x: 7, y: 4)
)
puts "  Test: #{test_final ? test_final.step_count : 'No Solution'} (corr: 11)"

step1_final = solve_part1(
  start: Node.new(odfn: 1362, x: 1, y: 1),
  target: Node.new(odfn: 1362, x: 31, y: 39)
)
puts "Part 1: #{step1_final ? step1_final.step_count : 'No Solution'} (corr: 82)"

step2_final = solve_part2(
  start: Node.new(odfn: 1362, x: 1, y: 1),
  max_steps: 50
)
puts "Part 2: #{step2_final} (corr: 138)"
