#!/usr/bin/env ruby

require 'trollop'
require 'pp'
require_relative '../lib/network_analysis'

opts = Trollop.options do
  version 'AoC:Puzzle08, (c) Florian Oberleitner (florian.oberleitner@gmail.com)'
  opt :input, 'Path to input data', type: String
end
Trollop.die :input, 'required' unless opts[:input]
Trollop.die :input, 'does not exists' unless File.exist?(opts[:input])

#########################################

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

  memo[from] = NetworkAnalysis::Node.new(from) unless memo.key?(from)
  memo[to] = NetworkAnalysis::Node.new(to) unless memo.key?(to)

  # assign destinations with distance for from/to node because edges are valid in both directions
  memo[from].connect_node(memo[to], distance)
  memo[to].connect_node(memo[from], distance)
end

puts 'Get all paths for all nodes...'
# Get all valid paths starting from each node
paths = nodes.values.each_with_object([]) do |node, memo|
  node.possible_chains.each do |path|
    memo << path if path.size == nodes.size
  end
end

puts 'Calculating lengths of each path...'
lengths =  paths.map do |path|
  length = 0
  (0..path.size - 2).each do |index|
    length += path[index].edge_value_for(path[index + 1])
  end
  length
end

puts "Puzzle09: Pt01: shortest=#{lengths.min}"
puts "Puzzle09: Pt02: longest=#{lengths.max}"
