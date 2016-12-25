#!/usr/bin/env ruby

require_relative '../lib/assembunny.rb'

if ARGV.size.zero?
  puts 'Please provide path to input file'
  exit 1
end

input = open(ARGV[0]).readlines.map(&:strip)

emulator1 = AssembunnyEmulator.new
emulator1.execute(source: input)
puts "Part 1: cycles:#{emulator1.cycles}, regs:#{emulator1.regs.inspect}, CORRECT:{a: 318077}"

emulator2 = AssembunnyEmulator.new
emulator2.execute(source: input, reg_init: { c: 1 })
puts "Part 2: cycles:#{emulator2.cycles}, regs:#{emulator2.regs.inspect}, CORRECT:{a: 9227731}"
