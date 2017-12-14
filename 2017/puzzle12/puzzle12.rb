#!/usr/bin/env ruby

require_relative '../../lib/node'

# Declare the number of the AOC17 puzzle
PUZZLE = 12

REX_ASSIGN = /^(?<prog>\d+) <-> (?<to_progs>[\d, ]+)$/

def create_progs(assignments)
  assignments.inject({}) do |progs, a|
    match = a.match(REX_ASSIGN)
    raise "Assignment '#{a}' not matched" unless match
    prog = match[:prog].to_i
    to_progs = match[:to_progs].split(/, */).map(&:to_i)
    # create nodes/progs if needed
    (to_progs + [prog]).each { |p| progs[p] = Node.new(name: p) unless progs.include? p }

    # set dependencies
    to_progs.each { |p| progs[prog].add_child(progs[p]) }
    progs
  end
end

# Declare all runs to be done for this puzzle
{
  test: {
    input: 'input_test.txt',
    target1: 6,
    target2: 2
  },
  puzzle: {
    skip: false,
    input: 'input.txt',
    target1: 283,
    target2: 195
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
  progs = create_progs(input)
  res1 = progs[0].collect_self_and_children.size
  res2 = progs.values.map { |p| p.collect_self_and_children.sort_by(&:name) }.uniq.size

  # Print result
  success_msg1 = res1 == run_pars[:target1] ? 'succeeded' : 'failed'
  success_msg2 = res2 == run_pars[:target2] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name}/1 #{success_msg1}: #{res1} (Target: #{run_pars[:target1]})"
  puts "AOC17-#{PUZZLE}/#{run_name}/2 #{success_msg2}: #{res2} (Target: #{run_pars[:target2]})"
  puts '=' * 50
end
