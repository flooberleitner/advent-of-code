#!/usr/bin/env ruby

require 'trollop'
require 'json'
require_relative '../lib/network_analysis'

opts = Trollop.options do
  version 'AoC:Puzzle13, (c) Florian Oberleitner (florian.oberleitner@gmail.com)'
  opt :input, 'Path to input data', type: String
end
Trollop.die :input, 'required' unless opts[:input]
Trollop.die :input, 'does not exists' unless File.exist?(opts[:input])

#########################################

seating_points_pattern = /(?<who>\w+) would (?<type>gain|lose) (?<points>\d+) happiness units by sitting next to (?<next_to_whom>\w+)/

def get_chains(persons)
  persons.values.first.possible_chains
end

def calc_points_for_chains(chains)
  chains.map do |chain|
    points = 0
    (0..chain.size - 2).each do |offset|
      # add points in chain from front to back
      points += chain[offset].edge_value_for(chain[offset + 1])
      # add points in chain from back to front
      points += chain[-1 - offset].edge_value_for(chain[-2 - offset])
    end
    # add points for wraparound front to back
    points += chain.first.edge_value_for(chain.last)
    # add points for wraparound back to front
    points += chain.last.edge_value_for(chain.first)
  end
end

instructions = File.readlines(opts[:input])

puts 'Reading all persons and assigning neigbor points...'
persons = instructions.each_with_object({}) do |inst, memo|
  fail "pattern did not match for 'inst'" unless seating_points_pattern.match(inst)
  m = Regexp.last_match
  who = m[:who]
  points = m[:type] == 'gain' ? m[:points].to_i : -m[:points].to_i
  next_to_whom = m[:next_to_whom]

  memo[who] = NetworkAnalysis::Node.new(who) unless memo.key?(who)
  memo[next_to_whom] = NetworkAnalysis::Node.new(next_to_whom) unless memo.key?(next_to_whom)

  memo[who].connect_node(memo[next_to_whom], points)
end

puts 'Getting all possible seating chains...'
chains = get_chains(persons)

puts 'Calculating points of all chains...'
chains_points = calc_points_for_chains(chains)

max_pt1 = chains_points.max
puts "Puzzle13: Pt01: most points=#{max_pt1}"

puts '====================================='

me = NetworkAnalysis::Node.new('Me')
persons.values.each do |obj|
  obj.connect_node(me, 0)
  me.connect_node(obj, 0)
end
persons['Me'] = me

puts 'Getting all possible seating chains...'
chains = get_chains(persons)

puts 'Calculating points of all chains...'
chains_points = calc_points_for_chains(chains)

max_pt2 = chains_points.max
puts "Puzzle13: Pt02: most points=#{max_pt2}"
