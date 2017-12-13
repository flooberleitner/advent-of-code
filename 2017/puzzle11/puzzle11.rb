#!/usr/bin/env ruby

# Declare the number of the AOC17 puzzle
PUZZLE = 11

# Position increments per direction
DIR_INCR = {
  n:  [0, 2],
  ne: [1, 1],
  se: [1, -1],
  s:  [0, -2],
  sw: [-1, -1],
  nw: [-1, 1]
}.freeze

def dist_to_center(pos)
  # solution is mirrored for all quadrants
  # -> transpose into 1st quadrant by using absolute values
  pa = pos.map(&:abs)

  # If we are above the 'x=y' diagonale we just need to move to
  # nearest x=0 point (takes x-amount of steps) and move the
  # remaining y-value (which is (y - x) / 2).
  # On or below the 'x=y' diagonale the value of x corresponds
  # to the steps needed.
  pa.first < pa.last ? pa.first + (pa.last - pa.first) / 2 : pa.first
end

def all_dist_from_center(movements)
  pos = [0, 0]
  movements.each_with_object([]) do |mv, dists|
    pos = pos.zip(DIR_INCR[mv]).map(&:sum)
    dists << dist_to_center(pos)
  end
end

# Declare all runs to be done for this puzzle
{
  test1: {
    input: 'ne,ne,ne',
    target1: 3,
    target2: 3
  },
  test2: {
    input: 'ne,ne,sw,sw',
    target1: 0,
    target2: 2
  },
  test3: {
    input: 'ne,ne,s,s',
    target1: 2,
    target2: 2
  },
  test4: {
    input: 'se,sw,se,sw,sw',
    target1: 3,
    target2: 3
  },
  puzzle: {
    skip: false,
    input: 'input.txt',
    target1: 696,
    target2: 1461
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
              file.readlines.map(&:strip).first
            end
          else
            # use input parameter directly
            run_pars[:input]
          end.split(/,\W*/).map(&:to_sym)

  # Process data
  dists = all_dist_from_center(input)
  res1 = dists.last
  res2 = dists.max

  # Print result
  success_msg1 = res1 == run_pars[:target1] ? 'succeeded' : 'failed'
  success_msg2 = res2 == run_pars[:target2] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name}/1 #{success_msg1}: #{res1} (Target: #{run_pars[:target1]})"
  puts "AOC17-#{PUZZLE}/#{run_name}/2 #{success_msg2}: #{res2} (Target: #{run_pars[:target2]})"
  puts '=' * 50
end
