#!/usr/bin/env ruby

require_relative '../../lib/duetemulator'
require 'thread'

# Declare the number of the AOC17 puzzle
PUZZLE = 18
# Declare all runs to be done for this puzzle
{
  test02: {
    skip: false,
    input: 'input_test2.txt',
    target: 3
  },
  puzzle02: {
    skip: false,
    input: 'input.txt',
    target: 6858
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

  queues = (0..1).map { Queue.new }
  emu0 = DuetEmulator.new(name: 'Emu0', source: input, queue_in: queues[0], queue_out: queues[1])
  emu1 = DuetEmulator.new(name: 'Emu1', source: input, queue_in: queues[1], queue_out: queues[0])

  [
    Thread.new { emu0.execute },
    Thread.new { emu1.execute(reg_init: { p: 1 }) }
  ].each(&:join)

  res = emu1.cmd_exec_count[:snd]

  # Print result
  success_msg = res == run_pars[:target] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name} #{success_msg}: #{res} (Target: #{run_pars[:target]})"
  puts '=' * 50
end
