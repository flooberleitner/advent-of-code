#!/usr/bin/env ruby

require_relative '../../lib/knot_hash'

# Declare the number of the AOC17 puzzle
PUZZLE = 10

# Declare all runs to be done for this puzzle
{
  test1: {
    sizes: '',
    hash_size: 256,
    target: 'a2582a3a0e66e6e86e3812dcb672a272'
  },
  test2: {
    sizes: 'AoC 2017',
    hash_size: 256,
    target: '33efeb34ea91902bb2f59c9920caa6cd'
  },
  test3: {
    sizes: '1,2,3',
    hash_size: 256,
    target: '3efbe78a8d82f29979031a4aa0b16a9d'
  },
  test4: {
    sizes: '1,2,4',
    hash_size: 256,
    target: '63960835bcdc130f0b66d7ff4f6a5a8e'
  },
  puzzle02: {
    sizes: '31,2,85,1,80,109,35,63,98,255,0,13,105,254,128,33',
    hash_size: 256,
    target: '28e7c4360520718a5dc811d3942cf1fd'
  }
}.each do |run_name, run_pars|
  # skip run?
  if run_pars[:skip]
    puts "Skipped '#{run_name}'"
    next
  end

  res = run_pars[:sizes].knot_hash

  # Print result
  success_msg = res == run_pars[:target] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name} #{success_msg}: #{res} (Target: #{run_pars[:target]})"
  puts '=' * 50
end
