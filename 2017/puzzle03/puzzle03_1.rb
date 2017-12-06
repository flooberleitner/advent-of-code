#!/usr/bin/env ruby

# Declare the number of the AOC17 puzzle
PUZZLE = 3

# Declare all runs to be done for this puzzle
RUNS = {
  test1: {
    input: 1,
    target: 0
  },
  test2: {
    input: 12,
    target: 3
  },
  test3: {
    input: 21,
    target: 4
  },
  test4: {
    input: 23,
    target: 2
  },
  test5: {
    input: 25,
    target: 4
  },
  test6: {
    input: 7,
    target: 2
  },
  test7: {
    input: 1024,
    target: 31
  },
  puzzle01: {
    input: 289_326,
    target: 419
  },
}.freeze

def main
  # Make each run
  RUNS.each do |name, data|
    # skip run?
    if data[:skip]
      puts "Skipped '#{name}'"
      next
    end

    # Process data
    res = steps_to_center(data[:input])

    # Print result
    success_msg = res == data[:target] ? 'succeeded' : 'failed'
    puts "AOC17-#{PUZZLE}/#{name} #{success_msg}: #{res} (Target: #{data[:target]})"
  end
end

def steps_to_center(start)
  return 0 if start == 1
  side_length = 1
  last_el_count = 0
  el_count = 1

  while el_count < start
    new_side_length = side_length + 2
    additional_el_count = new_side_length * 4 - 4
    side_length = new_side_length
    last_el_count = el_count
    el_count += additional_el_count
  end

  rings_to_walk = side_length / 2
  offset_in_current_ring = start - last_el_count - 1
  offset_on_side = (offset_in_current_ring + 1) % (side_length - 1)
  offset_from_center = (offset_on_side - side_length / 2).abs

  rings_to_walk + offset_from_center
end

main
