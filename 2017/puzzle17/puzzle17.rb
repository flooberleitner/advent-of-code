#!/usr/bin/env ruby

class Array
  def self.spinlock_feed(step_size:, insertion_max:)
    data = [0]
    pos = 0
    (1..insertion_max).each do |val|
      # print "\nRun: #{format('%8d', val)}" if (val % 100_000) == 1
      # print '.' if (val % 10_000) == 1
      next_pos = (pos + step_size) % data.size + 1
      if next_pos > data.size
        raise "Next Pos '#{next_pos}' out of range (size='#{data.size}')"
      end

      data.insert(next_pos, val)
      pos = next_pos
    end
    data
  end
end

# Declare the number of the AOC17 puzzle
PUZZLE = 17

# Declare all runs to be done for this puzzle
{
  test: {
    skip: false,
    step_size: 3,
    insertion_max: 2017,
    index_for: 2017,
    target: 638
  },
  puzzle01: {
    skip: false,
    step_size: 394,
    insertion_max: 2017,
    index_for: 2017,
    target: 926
  },
  puzzle02: {
    skip: true,
    step_size: 394,
    insertion_max: 50_000_000,
    index_for: 0,
    target: 0
  }
}.each do |run_name, run_pars|
  # skip run?
  if run_pars[:skip]
    puts "Skipped '#{run_name}'"
    next
  end

  # Process data
  a = Array.spinlock_feed(
    step_size: run_pars[:step_size],
    insertion_max: run_pars[:insertion_max]
  )
  res = a[a.index(run_pars[:index_for]) + 1]

  # Print result
  success_msg = res == run_pars[:target] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name} #{success_msg}: #{res} (Target: #{run_pars[:target]})"
  puts '=' * 50
end
