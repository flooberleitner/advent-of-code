#!/usr/bin/env ruby

require 'trollop'

opts = Trollop.options do
  version 'AoC:Puzzle07, (c) Florian Oberleitner (florian.oberleitner@gmail.com)'
  opt :input, 'Path to input data', type: String
end
Trollop.die :input, 'required' unless opts[:input]
Trollop.die :input, 'does not exists' unless File.exist?(opts[:input])

#########################################

op_pattern = /^(?<inp1>[a-z0-9]{0,2}) ?(?<op>RSHIFT|LSHIFT|AND|OR|NOT) ?(?<inp2>[a-z0-9]{1,2}) -> (?<target>[a-z]*)/
forward_pattern = /^(?<inp>[a-z0-9]{1,4}) -> (?<target>[a-z]{1,2})/

class Val
  def initialize(val)
    @val = val
  end
  attr_accessor :val

  def output
    puts "output:#{name}"
    @val
  end

  def name
    @val.to_s
  end
end

class Connect
  def initialize(name)
    @name = name
  end
  attr_reader :name
  attr_writer :input1

  def output
    puts "output:#{name}"
    return @input1.output if @input1
    fail "No inputs set for gate '#{name}'"
  end
end

class And < Connect
  attr_writer :input2

  def output
    puts "output:#{name}"
    return @input1.output & @input2.output if @input1 && @input2
    fail "No inputs set for gate '#{name}'"
  end
end

class Or < Connect
  attr_writer :input2

  def output
    puts "output:#{name}"
    return @input1.output | @input2.output if @input1 && @input2
    fail "No inputs set for gate '#{name}'"
  end
end

class Shift < Connect
  def initialize(name)
    super(name)
    @shift = 1
  end
  attr_writer :shift
end

class Rshift < Shift
  def output
    puts "output:#{name}"
    return @input1.output >> @shift if @input1 && @shift
    fail "No inputs set for gate '#{name}'"
  end
end

class Lshift < Shift
  def output
    puts "output:#{name}"
    return @input1.output << @shift if @input1 && @shift
    fail "No inputs set for gate '#{name}'"
  end
end

class Not < Connect
  def output
    puts "output:#{name}"
    return ~@input1.output if @input1
    fail "No inputs set for gate '#{name}'"
  end
end

instructions = File.readlines(opts[:input])

gates = {}
# create each gate
instructions.each do |inst|
  if op_pattern.match(inst)
    m = Regexp.last_match
    gate_class =  case m[:op].to_sym
                  when :AND then And
                  when :OR then Or
                  when :RSHIFT then Rshift
                  when :LSHIFT then Lshift
                  when :NOT then Not
                  else
                    fail "Op '#{m[:op]}' not recognized"
                  end
    gates[m[:target]] = gate_class.new(m[:target])
  elsif forward_pattern.match(inst)
    m = Regexp.last_match
    gates[m[:target]] = Connect.new(m[:target])
  else
    fail "No pattern matched for '#{inst}'"
  end
end

# add value inputs
instructions.each do |inst|
  inputs = []
  if op_pattern.match(inst)
    inputs << Regexp.last_match[:inp1]
    inputs << Regexp.last_match[:inp2]
  elsif forward_pattern.match(inst)
    inputs << Regexp.last_match[:inp]
  else
    fail "No pattern matched for '#{inst}'"
  end

  inputs.each do |inp|
    gates[inp] = Val.new(inp.to_i) unless gates.key?(inp) if /\d+/.match(inp)
  end
end

# assign inputs for each gate
instructions.each do |inst|
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
    when :OR
      gate.input1 = gates[src1]
      gate.input2 = gates[src2]
    when :RSHIFT
      gate.input1 = gates[src1]
      gate.shift = src2.to_i
    when :LSHIFT
      gate.input1 = gates[src1]
      gate.shift = src2.to_i
    when :NOT
      gate.input1 = gates[src2]
    end
  elsif forward_pattern.match(inst)
    gates[Regexp.last_match[:target]].input1 = gates[Regexp.last_match[:inp]]
  else
    fail "No pattern matched for '#{inst}'"
  end
end

puts "Puzzle07 Pt01: a=#{gates['a'].output}"
