#!/usr/bin/env ruby

require 'trollop'

opts = Trollop.options do
  version 'AoC:Puzzle19, (c) Florian Oberleitner (florian.oberleitner@gmail.com)'
  opt :input, 'Path to input data', type: String
end
Trollop.die :input, 'required' unless opts[:input]
Trollop.die :input, 'does not exists' unless File.exist?(opts[:input])

#########################################

lines = File.readlines(opts[:input])

input_molecule = lines[-1].strip

replacements = lines[0..-3].each_with_object([]) do |line, memo|
  fail "Line '#{line}' did not match the replacement pattern" unless /(?<from>\w+) => (?<to>\w+)/.match(line)
  memo << [Regexp.last_match(:from), Regexp.last_match(:to)]
end

puts input_molecule
puts replacements.inspect

possible_molecules = replacements.each_with_object([]) do |replacement, memo|
  start_search_at = 0
  substring = replacement[0]
  replace_with =  replacement[1]
  loop do
    found_at = input_molecule.index(substring, start_search_at)
    break unless found_at
    str = input_molecule[0, found_at]
    str += replace_with
    str += input_molecule[(found_at + substring.size)..-1]
    memo << str

    start_search_at = found_at + substring.size
  end
end.uniq

puts "Puzzle19: Part1: # of molecules: #{possible_molecules.size}"
