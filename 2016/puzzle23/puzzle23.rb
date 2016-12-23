#!/usr/bin/env ruby

class AssembunnyEmulator
  INSTRUCTION_PATTERN = /^(?<cmd>\w+)( (?<d1>-?[\d\w]+) ?)(?<d2>-?[\d\w]+)?$/

  def initialize(**reg_inits)
    @regs = Hash.new(0)
    reg_inits.each { |k, v| @regs[k] = v }
    @instructions = []
    @program_counter = 0
    @debug = false
    @cycles = 0
  end
  attr_reader :regs, :cycles

  def execute(program)
    load(program)
    puts "Instruction Count: #{@instructions.size}" if @debug
    while @program_counter < @instructions.size
      @cycles += 1
      instr = @instructions[@program_counter]
      puts "#{@cycles}: pc=#{@program_counter}, regs=#{@regs.inspect}, instr=#{instr.inspect}" if @debug
      inc_program_counter(send(instr[:cmd], instr[:data]))
    end
  end

  def enable_debug
    @debug = true
  end

  def disable_debug
    @debug = false
  end

  private def load(program)
    program.each do |line|
      m = line.match(INSTRUCTION_PATTERN)
      raise "Unknown Assembunny instruction '#{line}'" unless m
      @instructions << {
        cmd: m[:cmd].to_sym,
        data: [
          convert_instruction_data(m[:d1]),
          convert_instruction_data(m[:d2])
        ].compact
      }
    end
  end

  private def convert_instruction_data(data)
    return nil unless data
    data =~ /-?\d+/ ? data.to_i : data.to_sym
  end

  private def dec(inst_data)
    @regs[inst_data.first] -= 1 if inst_data.first.is_a? Symbol
    1
  end

  private def inc(inst_data)
    @regs[inst_data.first] += 1 if inst_data.first.is_a? Symbol
    1
  end

  private def jnz(inst_data)
    get_data_from(inst_data.first).zero? ? 1 : get_data_from(inst_data[1])
  end

  private def cpy(inst_data)
    if inst_data[1].is_a? Symbol
      @regs[inst_data[1]] = get_data_from(inst_data.first)
    end
    1
  end

  private def tgl(inst_data)
    toggle_idx = @program_counter + get_data_from(inst_data.first)
    # puts "tgl: d=#{inst_data.first}, r=#{@regs.inspect}, idx=#{toggle_idx}"
    return 1 if toggle_idx >= @instructions.size
    @instructions[toggle_idx][:cmd] = toggel_command(@instructions[toggle_idx])
    1
  end

  private def toggel_command(instr)
    case instr[:data].size
    when 1
      case instr[:cmd]
      when :inc then :dec
      else :inc
      end
    when 2
      case instr[:cmd]
      when :jnz then :cpy
      else :jnz
      end
    else
      raise "toggel_command: instruction data size '#{instr[:data].size}'"
    end
  end

  private def inc_program_counter(val = 1)
    @program_counter += val
  end

  private def get_data_from(id)
    id.is_a?(Symbol) ? @regs[id] : id
  end

  class InvalidInstructionError < StandardError
  end
end

# Part 2 takes far too long to run
#   -> transpile to C?
#   -> also think about what does the Assembunny code do, not just instruction by instruction
#      but in whole blocks of instructions
#      Maybe some parts can be optimized by introducing new instructions?
#
# Another ides: p_tseng wrote an optimiser for Assembunny code
#   -> https://www.reddit.com/r/adventofcode/comments/5jvbzt/2016_day_23_solutions/dbje1ik/
#   => look at that and maybe get some ideas about how a pro does it

[
  { lbl: 'Test 1', inp: 'puzzle23_input_test.txt', reg_init: {}, out: 3 },
  { lbl: 'Part 1', inp: 'puzzle23_part1_input.txt', reg_init: { a: 7 }, out: 11_424 },
  { lbl: 'Part 2', inp: 'puzzle23_part2_input.txt', reg_init: { a: 12 }, out: -1 }
].each do |p|
  input = open(p[:inp]).readlines.map(&:strip)
  emu = AssembunnyEmulator.new(p[:reg_init])
  emu.execute(input)
  puts "#{p[:lbl]}: cycles=#{emu.cycles}, reg[a]=#{emu.regs[:a]}" \
       "#{emu.regs[:a] == p[:out] ? '' : "  !!! corr.: #{p[:out]}"}"
end
