#!/usr/bin/env ruby

class Generator
  def initialize(factor:, start:, divider: nil)
    @factor = factor
    @start = start
    @val = @start
    @divider = divider
  end

  def next
    next_val
    (next_val until (@val % @divider).zero?) if @divider
    @val
  end

  private def next_val
    @val = (@val * @factor) % 0x7FFFFFFF
  end
end

# Declare the number of the AOC17 puzzle
PUZZLE = 15

# Declare all runs to be done for this puzzle
{
  test01: {
    inputA: 65,
    dividerA: nil,
    inputB: 8921,
    dividerB: nil,
    cycles: 5,
    target: 1
  },
  test02: {
    inputA: 65,
    dividerA: 4,
    inputB: 8921,
    dividerB: 8,
    cycles: 5_000_000,
    target: 309
  },
  puzzle01: {
    inputA: 277,
    inputB: 349,
    cycles: 40_000_000,
    target: 592
  },
  puzzle02: {
    inputA: 277,
    dividerA: 4,
    inputB: 349,
    dividerB: 8,
    cycles: 5_000_000,
    target: 320
  }
}.each do |run_name, run_pars|
  # skip run?
  if run_pars[:skip]
    puts "Skipped '#{run_name}'"
    next
  end

  # Process data
  gen_a = Generator.new(
    factor: 16_807,
    start: run_pars[:inputA],
    divider: run_pars[:dividerA]
  )
  gen_b = Generator.new(
    factor: 48_271,
    start: run_pars[:inputB],
    divider: run_pars[:dividerB]
  )

  res = 0
  run_pars[:cycles].times do |cycle|
    print format("\nCycle: %8d ", cycle) if (cycle % 10_000_000).zero?
    print '.' if (cycle % 1_000_000).zero?
    res += 1 if (gen_a.next & 0xFFFF) == (gen_b.next & 0xFFFF)
  end
  print "\n"

  # Print result
  success_msg = res == run_pars[:target] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name} #{success_msg}: #{res} (Target: #{run_pars[:target]})"
  puts '=' * 50
end
