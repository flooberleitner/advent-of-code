#!/usr/bin/env ruby

# Declare the number of the AOC17 puzzle
PUZZLE = 0

# Declare all runs to be done for this puzzle
RUNS = {
  test: {
    skip: true,
    input: 'input_test.txt',
    target: 0
  },
  puzzle01: {
    skip: true,
    input: 'input.txt',
    target: 0
  },
  puzzle02: {
    skip: true,
    input: 'input.txt',
    target: 0
  }
}.freeze

# Make each run
RUNS.each do |name, pars|
  # skip run?
  if pars[:skip]
    puts "Skipped '#{name}'"
    next
  end

  # open input data and process it
  open(pars[:input]) do |input|
    # Read all input lines and sanitize
    data = input.readlines.map(&:strip)

    # Process data
    res = 0

    # Print result
    success_msg = res == pars[:target] ? 'succeeded' : 'failed'
    puts "AOC17-#{PUZZLE}/#{name} #{success_msg}: #{res} (Target: #{pars[:target]})"
  end
end
