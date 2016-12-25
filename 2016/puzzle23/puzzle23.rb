#!/usr/bin/env ruby

require_relative '../lib/assembunny.rb'

emu = AssembunnyEmulator.new
[
  { lbl: 'Test 1', inp: 'puzzle23_input_test.txt', reg_init: {}, out: 3 },
  { lbl: 'Part 1', inp: 'puzzle23_part1_input.txt', reg_init: { a: 7 }, out: 11_424 },
  { lbl: 'Part 2', inp: 'puzzle23_part2_input.txt', reg_init: { a: 12 }, out: 479007984 }
].each do |p|
  input = open(p[:inp]).readlines.map(&:strip)
  emu.execute(source: input, reg_init: p[:reg_init])
  puts "#{p[:lbl]}: cycles=#{emu.cycles}, reg[a]=#{emu.regs[:a]}" \
       "#{emu.regs[:a] == p[:out] ? '' : "  !!! corr.: #{p[:out]}"}"
end
