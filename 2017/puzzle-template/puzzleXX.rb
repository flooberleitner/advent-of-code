#!/usr/bin/env ruby

# Declare the number of the AOC17 puzzle
PUZZLE = 0

# Declare all runs to be done for this puzzle
{
  test: {
    skip: true,
    input: 'input_test.txt',
    target1: 0,
    target2: 0
  },
  puzzle: {
    skip: true,
    input: 'input.txt',
    target1: 0,
    target2: 0
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
  res1 = 0
  res2 = 0

  # Print result
  success_msg1 = res1 == run_pars[:target1] ? 'succeeded' : 'failed'
  success_msg2 = res2 == run_pars[:target2] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name}/1 #{success_msg1}: #{res1} (Target: #{run_pars[:target1]})"
  puts "AOC17-#{PUZZLE}/#{run_name}/2 #{success_msg2}: #{res2} (Target: #{run_pars[:target2]})"
  puts '=' * 50
end
