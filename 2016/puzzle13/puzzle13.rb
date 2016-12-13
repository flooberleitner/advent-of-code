#!/usr/bin/env ruby

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
    n = [
      Node.new(odfn: @odfn, x: @x + 1, y: @y, step_count: step_count + 1),
      Node.new(odfn: @odfn, x: @x - 1, y: @y, step_count: step_count + 1),
      Node.new(odfn: @odfn, x: @x, y: @y + 1, step_count: step_count + 1),
      Node.new(odfn: @odfn, x: @x, y: @y - 1, step_count: step_count + 1)
    ].delete_if(&:wall?)
    return n if n.size < 2
    # My answer was too high so I did some random permutations on the
    # order of the neighbours to see if this has influence
    # -> it had!
    # Reason for my algorithm not finding the shortest path was, that
    # I did a DepthFirst (continue with element last added to queue) instead
    # of BreadthFirst (continue with oldest element in queue).
    n = n.permutation.to_a
    n[@prng.rand(n.size - 1)]
  end

  def eql?(other)
    @x == other.x && @y == other.y
  end

  def ==(other)
    eql?(other)
  end

  def solve_part1(target_node:)
    queued_nodes = [self]
    visited_nodes = []

    until queued_nodes.empty?
      node = queued_nodes.delete_at(0) # BreadthFirst -> continue with oldest
      visited_nodes.push(node)

      return node if node == target_node

      # We do not want to run in circles so we only visit neighbours
      # that were not visited already.
      node.neighbors.each do |n|
        queued_nodes.push n unless visited_nodes.include?(n)
      end
    end
    nil
  end

  def solve_part2(max_steps:)
    queued_nodes = [self]
    visited_nodes = []

    until queued_nodes.empty?
      node = queued_nodes.delete_at(0) # BreadthFirst -> continue with oldest
      visited_nodes.push(node) unless visited_nodes.include?(node)

      next if node.step_count == max_steps

      node.neighbors.each do |n|
        queued_nodes.push n unless visited_nodes.include?(n)
      end
    end
    visited_nodes.size
  end
end

test_final = Node.new(odfn: 10, x: 1, y: 1).solve_part1(target_node: Node.new(odfn: 10, x: 7, y: 4))
puts "  Test: #{test_final ? test_final.step_count : 'No Solution'} (corr: 11)"

step1_final = Node.new(odfn: 1362, x: 1, y: 1).solve_part1(target_node: Node.new(odfn: 1362, x: 31, y: 39))
puts "Part 1: #{step1_final ? step1_final.step_count : 'No Solution'} (corr: 82)"

step2_final = Node.new(odfn: 1362, x: 1, y: 1).solve_part2(max_steps: 50)
puts "Part 2: #{step2_final} (corr: 138)"
