#!/usr/bin/env ruby

# TODO: try a greedy approach from reverse with depth first
# (current implementation does not finish in reasonable time/memory)
require 'trollop'

opts = Trollop.options do
  version 'AoC:Puzzle19, (c) Florian Oberleitner (florian.oberleitner@gmail.com)'
  opt :input, 'Path to input data', type: String
end
Trollop.die :input, 'required' unless opts[:input]
Trollop.die :input, 'does not exists' unless File.exist?(opts[:input])

#########################################

lines = File.readlines(opts[:input])

target_molecule = lines[-1].strip

replacements = lines[0..-3].each_with_object([]) do |line, memo|
  fail "Line '#{line}' did not match the replacement pattern" unless /(?<from>\w+) => (?<to>\w+)/.match(line)
  memo << [Regexp.last_match(:to), Regexp.last_match(:from)]
end.sort do |a, b|
  b[0].size <=> a[0].size
end

def get_possible_molecules(input_molecule, replacements, memo_hash)
  ret = replacements.each do |replacement|
    start_search_at = 0
    substring = replacement[0]
    replace_with =  replacement[1]
    loop do
      found_at = input_molecule.index(substring, start_search_at)
      break unless found_at
      str = input_molecule[0, found_at]
      str += replace_with
      str += input_molecule[(found_at + substring.size)..-1]
      memo_hash[str] = 1

      start_search_at = found_at + substring.size
    end
  end
  ret
end

def get_minimum_step_size(start_molecule, replacements, target)
  molecules = {}
  get_possible_molecules(start_molecule, replacements, molecules)
  steps = 1
  until molecules.key?(target)
    steps += 1
    puts "========== #{steps}: molecules.size=#{molecules.size} ============"
    molecule_cnt = 0
    molecules = molecules.keys.each_with_object({}) do |molecule, memo|
      molecule_cnt += 1
      print '.' if molecule_cnt % 1_000 == 0
      print molecule_cnt if molecule_cnt % 10_000 == 0
      get_possible_molecules(molecule, replacements, memo)
    end
    puts ''
  end
  steps
end

puts "Puzzle19: Part2: # of steps: #{get_minimum_step_size(target_molecule, replacements, 'e')}"
