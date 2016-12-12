#!/usr/bin/env ruby

if ARGV.size.zero?
  puts 'Please provide path to input file'
  exit 1
end

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
    puts @instructions.size if @debug
    while @program_counter < @instructions.size
      @cycles += 1
      instr = @instructions[@program_counter]
      puts "#{@program_counter}: regs:#{@regs.inspect}, instr:#{instr.inspect}" if @debug
      send(instr[0], instr[1])
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
      @instructions << [
        m[:cmd].to_sym,
        [
          convert_instruction_data(m[:d1]),
          convert_instruction_data(m[:d2])
        ]
      ]
    end
  end

  private def convert_instruction_data(data)
    return nil unless data
    data =~ /-?\d+/ ? data.to_i : data.to_sym
  end

  private def dec(inst_data)
    @regs[inst_data[0]] -= 1
    inc_program_counter
  end

  private def inc(inst_data)
    @regs[inst_data[0]] += 1
    inc_program_counter
  end

  private def jnz(inst_data)
    inc_program_counter(get_data_from(inst_data.first).zero? ? 1 : inst_data[1])
  end

  private def cpy(inst_data)
    @regs[inst_data[1]] = get_data_from(inst_data.first)
    inc_program_counter
  end

  private def inc_program_counter(val = 1)
    @program_counter += val
  end

  private def get_data_from(id)
    id.is_a?(Symbol) ? @regs[id] : id
  end
end

input = open(ARGV[0]).readlines.map(&:strip)

emulator1 = AssembunnyEmulator.new
emulator1.execute(input)
puts "Part 1: cycles:#{emulator1.cycles}, regs:#{emulator1.regs.inspect}, CORRECT:{a: 318077}"

emulator2 = AssembunnyEmulator.new(c: 1)
emulator2.execute(input)
puts "Part 2: cycles:#{emulator2.cycles}, regs:#{emulator2.regs.inspect}, CORRECT:{a: 9227731}"
