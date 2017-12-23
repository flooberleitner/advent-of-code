#!/usr/bin/env ruby

def puzzle2_solution(insertion_max:, step_size:)
  target_pos = 1
  res = 0

  pos = 0
  (1..insertion_max).each do |val|
    # print "\nRun: #{format('%8d', val)}" if (val % 100_000) == 1
    # print '.' if (val % 10_000) == 1
    next_pos = (pos + step_size) % val + 1
    if next_pos > val
      raise "Next Pos '#{next_pos}' out of range (size='#{val}')"
    end
    pos = next_pos

    if pos < target_pos
      target_pos += 1
    elsif pos == target_pos
      res = val
    end
  end

  res
end

# Declare the number of the AOC17 puzzle
PUZZLE = 17

# Declare all runs to be done for this puzzle
{
  test: {
    skip: false,
    step_size: 3,
    insertion_max: 2017,
    target: 1226
  },
  puzzle02: {
    skip: false,
    step_size: 394,
    insertion_max: 50_000_000,
    target: 10_150_888
  }
}.each do |run_name, run_pars|
  # skip run?
  if run_pars[:skip]
    puts "Skipped '#{run_name}'"
    next
  end

  # Process data
  res = puzzle2_solution(
    insertion_max: run_pars[:insertion_max],
    step_size: run_pars[:step_size]
  )

  # Print result
  success_msg = res == run_pars[:target] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name} #{success_msg}: #{res} (Target: #{run_pars[:target]})"
  puts '=' * 50
end
