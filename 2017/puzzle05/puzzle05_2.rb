#!/usr/bin/env ruby

# Declare the number of the AOC17 puzzle
PUZZLE = 5

# Declare all runs to be done for this puzzle
RUNS = {
  test: {
    input: 'input_test.txt',
    target: 10
  },
  puzzle02: {
    input: 'input.txt',
    target: 27_502_966
  }
}.freeze

def main
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
      data = input.readlines.map(&:strip).map(&:to_i)

      # Process data
      res = jumps_till_exit(data)

      # Print result
      success_msg = res == pars[:target] ? 'succeeded' : 'failed'
      puts "AOC17-#{PUZZLE}/#{name} #{success_msg}: #{res} (Target: #{pars[:target]})"
    end
  end
end

def jumps_till_exit(jumps)
  jump_count = 0
  pos = 0

  while pos >= 0 && pos < jumps.size
    offset = jumps[pos]
    jumps[pos] += offset >= 3 ? -1 : 1
    pos += offset
    jump_count += 1
  end

  jump_count
end

main
