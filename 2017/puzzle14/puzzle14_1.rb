#!/usr/bin/env ruby

require_relative '../../lib/knot_hash'

def calc_used_squares(key)
  (0..127).map do |line_num|
    "#{key}-#{line_num}".knot_hash.to_i(16).to_s(2).chars.map(&:to_i).sum
  end.sum
end

# Declare the number of the AOC17 puzzle
PUZZLE = 14

# Declare all runs to be done for this puzzle
{
  test: {
    input: 'flqrgnkx',
    target: 8108
  },
  puzzle01: {
    skip: false,
    input: 'xlqgujun',
    target: 8204
  }
}.each do |run_name, run_pars|
  # skip run?
  if run_pars[:skip]
    puts "Skipped '#{run_name}'"
    next
  end

  # open input data and process it
  input = if File.exist?(run_pars[:input])
            open(run_pars[:input]) do |file|
              # Read all input lines and sanitize
              file.readlines.map(&:strip)
            end
          else
            # use input parameter directly
            run_pars[:input]
          end

  # Process data
  res = calc_used_squares(input)

  # Print result
  success_msg1 = res == run_pars[:target] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name} #{success_msg1}: #{res} (Target: #{run_pars[:target]})"
  puts '=' * 50
end
