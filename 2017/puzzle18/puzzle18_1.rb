#!/usr/bin/env ruby

require_relative '../../lib/duetemulator'

# Declare the number of the AOC17 puzzle
PUZZLE = 18
# Declare all runs to be done for this puzzle
{
  test: {
    skip: false,
    input: 'input_test1.txt',
    target: 4
  },
  puzzle01: {
    skip: false,
    input: 'input.txt',
    target: 4601
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
  emu = DuetEmulator.new(name: 'Emu', source: input)
  # emu.enable_debug
  res = emu.execute

  # Print result
  success_msg = res == run_pars[:target] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name} #{success_msg}: #{res} (Target: #{run_pars[:target]})"
  puts '=' * 50
end
