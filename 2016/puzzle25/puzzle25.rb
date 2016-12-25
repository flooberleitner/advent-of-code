#!/usr/bin/env ruby

require_relative '../lib/assembunny.rb'

class Puzzle25Emulator < AssembunnyEmulator
  def initialize(source: nil)
    super
    add_optimizer :optimize_dec_by
    @instructions = optimize(@instructions_toggled)
    @clock = ''
  end
  attr_reader :clock

  private def out(args)
    # @instructions.each { |i| puts "#{i[:cmd]} #{i[:args].join(' ')}" }
    # exit
    @clock << get_data_from(args.first).to_s
    raise AbortExecutionError if @clock.size >= 4
  end

  private def optimize_dec_by(instructions)
    # Sequence
    #   jnz c 2
    #   jnz 1 4
    #   dec b
    #   dec c
    #   jnz 1 -4
    # is a 'b -= c' which can be expressed as a 2 arg dec_by 'dec_by b, c'
    # leaving c with 0.
    pattern_size = 5
    instructions.each_cons(pattern_size).with_index do |(i1, i2, i3, i4, i5), idx|
      next unless i1[:cmd] == :jnz &&
                  i2[:cmd] == :jnz &&
                  i3[:cmd] == :dec &&
                  i4[:cmd] == :dec &&
                  i5[:cmd] == :jnz &&
                  i1[:args].first.is_a?(Symbol) &&
                  i3[:args].first.is_a?(Symbol) &&
                  i4[:args].first.is_a?(Symbol) &&
                  (
                    i1[:args].first == i3[:args].first ||
                    i1[:args].first == i4[:args].first
                  ) &&
                  i1[:args][1] == 2 &&
                  i2[:args] == [1, 4] &&
                  i5[:args] == [1, -4]
      by = i1[:args].first
      # 'which_reg' is the reg that is decremented other than the 'by' reg
      which_reg = [i3[:args].first, i3[:args].first]
      which_reg.delete(by)
      which_reg = which_reg.first
      instructions[idx] = {
        cmd: :dec_by_opt,
        args: [
          which_reg,
          by,
          5
        ].freeze
      }.freeze
      (pattern_size - 1).times do |i|
        instructions[idx + 1 + i] = { cmd: :nop, args: [].freeze }.freeze
      end
    end
  end

  private def dec_by_opt(args)
    @regs[args.first] -= get_data_from(args[1])
    @regs[args[1]] = 0
    inc_program_counter(args.last)
  end
end

# TODO
# Far too slow to make an effective search
# -> check what pattern the instructions from line 10 -> 29/30 represent and find an optimisation for that
#    because this runs for longer and longer the higher reg[:a] is set
source_code = open('puzzle25_part1_input.txt').readlines.map(&:strip)
emu = Puzzle25Emulator.new(source: source_code)
# emu.enable_debug
100_000.times do |idx|
  puts "idx=#{idx}" if (idx % 100).zero?
  emu.execute(reg_init: { a: idx })
  if emu.clock == '0101'
    puts "Part 1: #{idx}"
    break
  end
end
