#!/usr/bin/env ruby

class Array
  def knot_hash(sizes:, rounds: 1)
    dup = clone
    rotate_cnt = 0 # used to reverse the overall rotation after we are finished
    skip_size = 0
    rounds.times do
      sizes.each do |size|
        sub = dup.slice(0, size)
        dup.replace(sub.reverse + dup[size..-1])
        dup.rotate!(size + skip_size)
        rotate_cnt += size + skip_size
        skip_size += 1
      end
    end
    dup.rotate!(-rotate_cnt)
  end
end

# Declare the number of the AOC17 puzzle
PUZZLE = 10

# Declare all runs to be done for this puzzle
{
  test: {
    sizes: '3, 4, 1, 5',
    hash_size: 5,
    target: 12
  },
  puzzle01: {
    sizes: '31, 2, 85, 1, 80, 109, 35, 63, 98, 255, 0, 13, 105, 254, 128, 33',
    hash_size: 256,
    target: 6_952
  }
}.each do |run_name, run_pars|
  # skip run?
  if run_pars[:skip]
    puts "Skipped '#{run_name}'"
    next
  end

  sizes = run_pars[:sizes].split(/, /).map(&:to_i)
  input = (0...run_pars[:hash_size]).to_a

  hashed = input.knot_hash(sizes: sizes)

  # Process data
  res = hashed[0] * hashed[1]

  # Print result
  success_msg = res == run_pars[:target] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name} #{success_msg}: #{res} (Target: #{run_pars[:target]})"
  puts '=' * 50
end
