#!/usr/bin/env ruby

class Storage
  def initialize(input)
    # lookup the first node
    first_node = 0
    first_node += 1 until input[first_node] =~ Node::PATTERN

    # parse nodes
    @nodes = input[first_node..-1].map do |line|
      m = line.match(Node::PATTERN)
      if m
        raise "Mismatched size/used/avail: #{line}" if m[:size].to_i != m[:used].to_i + m[:avail].to_i
        Node.new(x: m[:x].to_i, y: m[:y].to_i, size: m[:size].to_i, used: m[:used].to_i)
      else
        raise "Unknown node pattern '#{line}'"
      end
    end
  end
  attr_reader :nodes

  def viable_pairs
    @nodes.combination(2).map do |c|
      check = ->(nodes) { nodes[0].viable_with(nodes[1]) }
      next c if check.call(c)
      # check reversed direction
      c.reverse!
      next c if check.call(c)
      nil
    end.compact
  end

  class Node
    PATTERN = /^\/dev\/grid\/node-x(?<x>\d+)-y(?<y>\d+) +(?<size>\d+)T +(?<used>\d+)T +(?<avail>\d+)T.+$/
    def initialize(x:, y:, size:, used: 0)
      @x = x
      @y = y
      @size = size
      @used = used
    end
    attr_reader :x, :y, :size, :used

    def avail
      @size - @used
    end

    def empty?
      @used == 0
    end

    def viable_with(other)
      return false if empty?
      return false if self == other
      return false if used > other.avail
      true
    end
  end
end

[
  {
    title: 'Part 1',
    input: 'puzzle22_input.txt',
    expected: 960
  }
].each do |p|
  input = open(p[:input]).readlines.map(&:strip)
  storage = Storage.new(input)
  puts p[:title]
  puts "  Storage Size: #{storage.nodes.size}"
  res = storage.viable_pairs.size
  puts "  Viable Pairs: #{res}#{res == p[:expected] ? '' : " !!! corr: #{p[:expected]}"}"
end
