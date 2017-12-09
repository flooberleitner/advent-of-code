#!/usr/bin/env ruby

require 'english'

class Statement
  @rex = /^(?<instr>.*) if (?<cond>.*)$/

  def self.rex
    @rex
  end

  def initialize(source)
    Statement.rex.match(source)
    if $LAST_MATCH_INFO.nil?
      raise ArgumentError, "Statement '#{source}' did not match"
    end
    @instruction = Instruction.new($LAST_MATCH_INFO[:instr])
    @condition = Condition.new($LAST_MATCH_INFO[:cond])
  end

  def execute(registers)
    @instruction.execute(registers) if @condition.execute(registers)
  end
end

class Expression
  @rex = /^(?<reg>[a-zA-Z]+) (?<op>[a-z<>=!]+) (?<val>-?\d+)$/

  def self.rex
    @rex
  end

  def initialize(source)
    @source = source
    Expression.rex.match(source)
    if $LAST_MATCH_INFO.nil?
      raise ArgumentError, "Expression '#{source}' did not match"
    end
    @reg = $LAST_MATCH_INFO[:reg].to_sym
    @op = $LAST_MATCH_INFO[:op]
    unless supported_ops.include? @op
      raise ArgumentError, "Operation '#{@op}' in '#{source}' not supported"
    end
    @val = $LAST_MATCH_INFO[:val].to_i
  end
  attr_reader :source

  def execute(_registers)
    raise "Not implemented by class #{self.class.name}"
  end

  private def supported_ops
    @supported_ops ||= []
  end
end

class Instruction < Expression
  def initialize(source)
    super source
  end

  def execute(registers)
    case @op
    when 'inc' then registers[@reg] += @val
    when 'dec' then registers[@reg] -= @val
    else raise "Op '#{@op}' not implemented"
    end
    true
  end

  private def supported_ops
    @supported_ops ||= %w(inc dec)
  end
end

class Condition < Expression
  def initialize(source)
    super source
  end

  def execute(registers)
    case @op
    when '==' then registers[@reg] == @val
    when '!=' then registers[@reg] != @val
    when '<=' then registers[@reg] <= @val
    when '>=' then registers[@reg] >= @val
    when '<' then registers[@reg] < @val
    when '>' then registers[@reg] > @val
    else raise "Op '#{@op}' not implemented"
    end
  end

  private def supported_ops
    @supported_ops ||= %w(== <= >= != > <)
  end
end

class Computer
  def initialize
    @registers = Hash.new(0)
    @registers['FooBarFizzBuzz'] = 0
    @reg_max = 0
  end
  attr_reader :registers, :reg_max

  def run_statements(statements)
    statements.each do |s|
      s.execute(@registers)
      track_reg_max
    end
  end

  def biggest_reg
    @registers.sort_by { |_name, val| val }.last
  end

  private def track_reg_max
    @reg_max = [@registers.values.max, @reg_max].max
  end
end

# Declare the number of the AOC17 puzzle
PUZZLE = 8

# Declare all runs to be done for this puzzle
{
  test: {
    input: 'input_test.txt',
    target1: 1,
    target2: 10
  },
  puzzle: {
    input: 'input.txt',
    target1: 2971,
    target2: 4254
  }
}.each do |name, pars|
  # skip run?
  if pars[:skip]
    puts "Skipped '#{name}'"
    next
  end

  # open input data and process it
  open(pars[:input]) do |input|
    # Read all input lines and sanitize
    statements = input.readlines.map(&:strip).map { |line| Statement.new(line) }
    computer = Computer.new
    computer.run_statements(statements)

    res1 = computer.biggest_reg.last
    res2 = computer.reg_max

    # Print result
    success_msg1 = res1 == pars[:target1] ? 'succeeded' : 'failed'
    success_msg2 = res2 == pars[:target2] ? 'succeeded' : 'failed'
    puts "AOC17-#{PUZZLE}/#{name}1 #{success_msg1}: #{res1} (Target: #{pars[:target1]})"
    puts "AOC17-#{PUZZLE}/#{name}2 #{success_msg2}: #{res2} (Target: #{pars[:target2]})"
  end
end
