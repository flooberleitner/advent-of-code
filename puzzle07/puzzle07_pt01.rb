#!/usr/bin/env ruby

require 'trollop'

opts = Trollop.options do
  version 'AoC:Puzzle07, (c) Florian Oberleitner (florian.oberleitner@gmail.com)'
  opt :input, 'Path to input data', type: String
end
Trollop.die :input, 'required' unless opts[:input]
Trollop.die :input, 'does not exists' unless File.exist?(opts[:input])

#########################################

module Observable
  module Observed
    def register(obj)
      @observers ||= []
      @observers << obj unless @observers.member?(obj) if obj
    end

    def unregister(obj)
      @observers ||= []
      @observers.delete(obj)
    end

    def notify_observers
      @observers ||= []
      @observers.each(&:observed_changed)
    end
  end

  module Observer
    def observed_changed
      fail 'Observer did not implement observed_changed'
    end
  end
end

class Gate
  include Observable::Observed
  include Observable::Observer

  def initialize(name)
    @name = name
    @output = 0xFFFFFFFF
    @inputs = []
  end
  attr_reader :name, :output

  def method_missing(method, *args, &block)
    case method.to_s
    when /input(?<inp>[0-9])*=\z/
      # extract input number
      inp = Regexp.last_match[:inp].to_i
      inp = 0 unless inp
      # define input setter for future use
      define_singleton_method(method) do |input|
        @inputs[inp].unregister(self) if @inputs[inp]
        @inputs[inp] = input
        @inputs[inp].register(self)
        @output = apply_logic
      end

      # for whatever reason define_singlton_method returns just a Symbol
      # and not the new method as Proc (as state in 2.2.0 doc)
      # -> call defined input setter by hand
      method(method).call(*args)
    when /input(?<inp>[0-9])*\z/
      # extract input number
      inp = Regexp.last_match(:inp).to_i
      inp = 0 unless inp
      # define input getter for future use
      define_singleton_method(method) { @inputs[inp] }
      # call defined input getter by hand
      method(method).call(*args)
    else
      super
    end
  end

  # Expected to return the new output value based on input values and logic
  def apply_logic
    fail 'apply_logic not implemented'
  end

  # if inputs where reassigned this needs to be called when finished
  def inputs_stable
    notify_observers
  end

  def observed_changed
    new_output = apply_logic
    return if @output == new_output
    @output = new_output
    notify_observers
  end
end

class Value < Gate
  def initialize(name)
    super(name)
    @output = name.to_i
  end

  def input=(value)
    @output = value
  end
end

class Connect < Gate
  def apply_logic
    @inputs[0].output
  end
end

class And < Gate
  def apply_logic
    inp1 = input1 ? input1.output : 0xFFFFFFFF
    inp2 = input2 ? input2.output : 0xFFFFFFFF
    inp1 & inp2
  end
end

class Or < Gate
  def apply_logic
    inp1 = input1 ? input1.output : 0x00000000
    inp2 = input2 ? input2.output : 0x00000000
    inp1 | inp2
  end
end

class Shift < Gate
  attr_accessor :shift

  def apply_logic
    inp = input ? input.output : 0x00000000
    shift = @shift ? @shift : 1
    shift_operation(inp, shift)
  end

  def shift_operation(value, shift)
    fail 'shift_operation not implemented'
  end
end

class RShift < Shift
  def shift_operation(value, shift)
    value >> shift
  end
end

class LShift < Shift
  def shift_operation(value, shift)
    value << shift
  end
end

class Not < Gate
  def apply_logic
    inp = input ? input.output : 0x00000000
    ~inp
  end
end

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
                  when :AND then And
                  when :OR then Or
                  when :RSHIFT then RShift
                  when :LSHIFT then LShift
                  when :NOT then Not
                  else
                    fail "Op '#{m[:op]}' not recognized"
                  end
    gates[target] = gate_class.new(target)
  elsif forward_pattern.match(inst)
    target = Regexp.last_match[:target]
    gates[target] = Connect.new(target)
  else
    fail "No pattern matched for '#{inst}'"
  end
end

puts 'Adding value inputs...'
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
    gates[inp] = Value.new(inp.to_i) unless gates.key?(inp) if /\d+/.match(inp)
  end
end

print 'Assigning inputs...'
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
gates[val_a] = Value.new(val_a)
gate_b = gates['b']
gate_b.input = gates[val_a]
gate_b.inputs_stable
puts "Puzzle07 Pt02: a=#{gates['a'].output}"
