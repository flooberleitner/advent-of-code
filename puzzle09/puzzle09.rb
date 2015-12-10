#!/usr/bin/env ruby

require 'trollop'
require 'pp'

opts = Trollop.options do
  version 'AoC:Puzzle08, (c) Florian Oberleitner (florian.oberleitner@gmail.com)'
  opt :input, 'Path to input data', type: String
end
Trollop.die :input, 'required' unless opts[:input]
Trollop.die :input, 'does not exists' unless File.exist?(opts[:input])

#########################################

class Node
  def initialize(name)
    @name = name
    @destinations = {}
    @sources = {}
  end
  attr_reader :name, :destinations, :sources

  def add_destination(node, distance)
    @destinations[node] = distance unless @destinations.key?(node)
  end

  def distance_to(node)
    @destinations[node]
  end

  def get_all_possible_destination_paths(nodes_to_ignore = [])
    nodes_to_check = @destinations.keys - nodes_to_ignore
    return [[self]] if nodes_to_check.empty?

    nodes_to_ignore << self

    # get all paths of all destinations and insert this node at first element
    paths = nodes_to_check.each_with_object([]) do |node, memo|
      node.get_all_possible_destination_paths(nodes_to_ignore).each do |path|
        memo << path.insert(0, self)
      end
    end

    nodes_to_ignore.delete(self)
    paths
  end
end

puts 'Reading edges...'
edges = File.readlines(opts[:input])

puts 'Creating nodes...'
# get each node with with its destination and distance
edge_pattern = /(?<from>[\w]+) to (?<to>[\w]+) = (?<dist>[\d]+)/
nodes = edges.each_with_object({}) do |edge, memo|
  fail "edge '#{edge}' did not match pattern" unless edge_pattern.match(edge)
  from = Regexp.last_match(:from)
  to = Regexp.last_match(:to)
  distance = Regexp.last_match(:dist).to_i

  memo[from] = Node.new(from) unless memo.key?(from)
  memo[to] = Node.new(to) unless memo.key?(to)

  # assign destinations with distance for from/to node because edges are valid in both directions
  memo[from].add_destination(memo[to], distance)
  memo[to].add_destination(memo[from], distance)
end

puts 'Get all paths for all nodes...'
# Get all valid paths starting from each node
paths = nodes.values.each_with_object([]) do |node, memo|
  node.get_all_possible_destination_paths.each do |path|
    memo << path if path.size == nodes.size
  end
end

puts 'Calculating lengths of each path...'
lengths =  paths.map do |path|
  length = 0
  (0..path.size - 2).each do |index|
    length += path[index].distance_to(path[index + 1])
  end
  length
end

puts "Puzzle09: Pt01: shortest=#{lengths.min}"
puts "Puzzle09: Pt02: longest=#{lengths.max}"
