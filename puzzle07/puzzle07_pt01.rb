#!/usr/bin/env ruby

require 'trollop'
require_relative 'observe_it'
require_relative 'gates.rb'

opts = Trollop.options do
  version 'AoC:Puzzle07, (c) Florian Oberleitner (florian.oberleitner@gmail.com)'
  opt :input, 'Path to input data', type: String
end
Trollop.die :input, 'required' unless opts[:input]
Trollop.die :input, 'does not exist' unless File.exist?(opts[:input])

#########################################

puts 'Reading instructions...'
instructions = File.readlines(opts[:input])

op_pattern = /^(?<inp1>[a-z0-9]{0,2}) ?(?<op>RSHIFT|LSHIFT|AND|OR|NOT) ?(?<inp2>[a-z0-9]{1,2}) -> (?<target>[a-z]*)/
forward_pattern = /^(?<inp>[a-z0-9]{1,}) -> (?<target>[a-z]{1,2})/

gates = {}
puts 'Creating gates...'
instructions.each do |inst|
  if op_pattern.match(inst)
    op = Regexp.last_match[:op]
    target = Regexp.last_match[:target]
    gate_class =  case op.to_sym
                  when :AND then Gates::And
                  when :OR then Gates::Or
                  when :RSHIFT then Gates::RShift
                  when :LSHIFT then Gates::LShift
                  when :NOT then Gates::Not
                  else
                    fail "Op '#{m[:op]}' not recognized"
                  end
    gates[target] = gate_class.new(target)
  elsif forward_pattern.match(inst)
    target = Regexp.last_match[:target]
    gates[target] = Gates::Connection.new(target)
  else
    fail "No pattern matched for '#{inst}'"
  end
end

puts 'Adding input values...'
instructions.each do |inst|
  values = []
  if op_pattern.match(inst)
    values << Regexp.last_match[:inp1]
    values << Regexp.last_match[:inp2]
  elsif forward_pattern.match(inst)
    values << Regexp.last_match[:inp]
  else
    fail "No pattern matched for '#{inst}'"
  end

  values.each do |val|
    break unless /\d+/.match(val)
    gates[val] = Gates::Value.new(val) unless gates.key?(val)
    gates[val].output = val.to_i
  end
end

print 'Setting up connections...'
instructions.each_index do |index|
  print '.' if index % 10 == 0
  print index.to_s if index % 50 == 0

  inst = instructions[index]
  if op_pattern.match(inst)
    src1 = Regexp.last_match[:inp1]
    src2 = Regexp.last_match[:inp2]
    op = Regexp.last_match[:op]
    target = Regexp.last_match[:target]
    gate = gates[target]
    case op.to_sym
    when :AND
      gate.input1 = gates[src1]
      gate.input2 = gates[src2]
      gate.inputs_stable
    when :OR
      gate.input1 = gates[src1]
      gate.input2 = gates[src2]
      gate.inputs_stable
    when :RSHIFT
      gate.input = gates[src1]
      gate.shift = src2.to_i
      gate.inputs_stable
    when :LSHIFT
      gate.input = gates[src1]
      gate.shift = src2.to_i
      gate.inputs_stable
    when :NOT
      gate.input = gates[src2]
      gate.inputs_stable
    end
  elsif forward_pattern.match(inst)
    gate = gates[Regexp.last_match[:target]]
    gate.input = gates[Regexp.last_match[:inp]]
    gate.inputs_stable
  else
    fail "No pattern matched for '#{inst}'"
  end
end

puts ''
puts "Puzzle07 Pt01: a=#{gates['a'].output}"

puts '----------------------------------------'
puts 'Reassigning inputs for part 2'

val_a = gates['a'].output.to_s
gates[val_a] = Gates::Value.new(val_a)
gates[val_a].output = val_a.to_i
gate_b = gates['b']
gate_b.input = gates[val_a]
gate_b.inputs_stable
puts "Puzzle07 Pt02: a=#{gates['a'].output}"
