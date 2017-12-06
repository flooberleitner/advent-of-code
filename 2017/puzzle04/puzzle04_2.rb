#!/usr/bin/env ruby

# Declare the number of the AOC17 puzzle
PUZZLE = 4

# Declare all runs to be done for this puzzle
RUNS = {
  test: {
    input: 'input2_test.txt',
    target: 3
  },
  puzzle02: {
    input: 'input.txt',
    target: 231
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
      data = input.readlines.map(&:strip)

      # Process data
      res = valid_phrase_count(data)

      # Print result
      success_msg = res == pars[:target] ? 'succeeded' : 'failed'
      puts "AOC17-#{PUZZLE}/#{name} #{success_msg}: #{res} (Target: #{pars[:target]})"
    end
  end
end

class String
  def sort_ascending
    split(//).sort.join
  end
end

def valid_phrase_count(phrases)
  phrases.map { |p| p.split.map(&:sort_ascending) }.map { |p| p.size == p.uniq.size ? 1 : 0 }.sum
end

main
