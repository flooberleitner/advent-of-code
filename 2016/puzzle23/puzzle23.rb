#!/usr/bin/env ruby

##
# Assembunny Emulator implementation.
# 2016/23 part 2 took faaaaar too long to run
# There was also the hint to make some optimisations
# -> took a look at the code and also some of the solutions
# p_tseng implemented a clever optimiser which was inspiration for the
# optimizer part (https://www.reddit.com/r/adventofcode/comments/5jvbzt/2016_day_23_solutions/dbje1ik/)
class AssembunnyEmulator
  INSTRUCTION_PATTERN = /^(?<cmd>\w+)( (?<d1>-?[\d\w]+) ?)(?<d2>-?[\d\w]+)?$/

  def initialize
    @debug = false
    reset_emulator
  end
  attr_reader :regs, :cycles

  ##
  # Execute the provided Assembunny sourcecode.
  # Register bank is initialized with given values.
  def execute(source:, reg_init: {})
    reset_emulator
    @regs.merge! reg_init
    @instructions_original = load(source)
    @instructions_toggled = @instructions_original.map(&:dup)
    @instructions = optimize(@instructions_toggled)
    @instructions.each { |i| puts i.inspect } if @debug
    puts "Instruction Count: #{@instructions.size}" if @debug
    while @program_counter < @instructions.size
      @cycles += 1
      instr = @instructions[@program_counter]
      puts "#{@cycles}: pc=#{@program_counter}, regs=#{@regs.inspect}, instr=#{instr.inspect}" if @debug
      send(instr[:cmd], instr[:args])
    end
  end

  ##
  # Enable debug outputs
  def enable_debug
    @debug = true
  end

  ##
  # Disable debug outputs
  def disable_debug
    @debug = false
  end

  ##
  # Resets the internal state of the emulator
  private def reset_emulator
    @regs = Hash.new(0)
    @instructions = []
    @program_counter = 0
    @cycles = 0
  end

  ##
  # Load instructions from source code
  # Returns an array of instructions.
  # In instruction is a hash {cmd: :COMMAND, :args [ARGUMENTS]}
  private def load(source)
    source.map do |line|
      m = line.match(INSTRUCTION_PATTERN)
      raise "Unknown Assembunny instruction '#{line}'" unless m
      {
        cmd: m[:cmd].to_sym,
        args: [
          convert_instruction_arg(m[:d1]),
          convert_instruction_arg(m[:d2])
        ].compact.freeze
      }.freeze
    end.freeze
  end

  ##
  # Convert an instruction argument to argument types used in emulator.
  private def convert_instruction_arg(arg)
    return nil unless arg
    arg =~ /-?\d+/ ? arg.to_i : arg.to_sym
  end

  ##
  # Take instructions and parse them for optimisations
  # Returns optimized instruction list as new array.
  private def optimize(instructions)
    optimized = instructions.dup

    # inc_by_mul first becaus inc_by is a sub of this sequence
    optimize_inc_by_mul(optimized)
    optimize_inc_by(optimized)

    optimized.freeze
  end

  ##
  # Optimize inc_by pattern in place in +instructions+
  def optimize_inc_by(instructions)
    # Sequence
    #   inc a
    #   dec c
    #   jnz c -2
    # is a 'a += c' which can be expressed as a 2 arg inc 'inc a, c'
    # leaving c with 0.
    instructions.each_cons(3).with_index do |(i1, i2, i3), idx|
      next unless i1[:cmd] == :inc &&
                  i2[:cmd] == :dec &&
                  i3[:cmd] == :jnz &&
                  i2[:args].first == i3[:args].first && i3[:args][1] == -2
      instructions[idx] = {
        cmd: :inc,
        args: [
          i1[:args].first,
          i2[:args].first
        ].freeze
      }.freeze
      instructions[idx + 1] = { cmd: :nop, args: {}.freeze }.freeze
      instructions[idx + 2] = { cmd: :nop, args: {}.freeze }.freeze
    end
  end

  ##
  # Optimize inc_by pattern in place in +instructions+.
  def optimize_inc_by_mul(instructions)
    # Sequence 2
    #   cpy b c
    #   inc a
    #   dec c
    #   jnz c -2
    #   dec d
    #   jnz d -5
    # is a 'a += b * d' which will be a new inc with 4 args 'inc, [a, b, d, c]'
    # leaving c&d with 0.
    # b could also be a constant number
    instructions.each_cons(6).with_index do |(i1, i2, i3, i4, i5, i6), idx|
      next unless i1[:cmd] == :cpy &&
                  i2[:cmd] == :inc &&
                  i3[:cmd] == :dec &&
                  i4[:cmd] == :jnz &&
                  i5[:cmd] == :dec &&
                  i6[:cmd] == :jnz &&
                  i3[:args].first == i4[:args].first && i4[:args][1] == -2 &&
                  i5[:args].first == i6[:args].first && i6[:args][1] == -5
      instructions[idx] = {
        cmd: :inc,
        args: [
          i2[:args].first,
          i1[:args].first,
          i5[:args].first,
          i1[:args][1]
        ].freeze
      }.freeze
      instructions[idx + 1] = { cmd: :nop, args: {}.freeze }.freeze
      instructions[idx + 2] = { cmd: :nop, args: {}.freeze }.freeze
      instructions[idx + 3] = { cmd: :nop, args: {}.freeze }.freeze
      instructions[idx + 4] = { cmd: :nop, args: {}.freeze }.freeze
      instructions[idx + 5] = { cmd: :nop, args: {}.freeze }.freeze
    end
  end

  ##
  # NOP instruction
  # Does nothing, just increased program counter
  private def nop(_args)
    inc_program_counter
  end

  ##
  # DEC instruction
  # Decrement given register
  private def dec(args)
    @regs[args.first] -= 1 if args.first.is_a? Symbol
    inc_program_counter
  end

  ##
  # INC instruction
  # Increment given register based on number or arguments.
  # Execution is done in specialized incrementers
  private def inc(args)
    case args.size
    when 1 then inc1(args)
    when 2 then inc2(args)
    when 4 then inc4(args)
    else
      raise "inc: instruction data size '#{args.size}'"
    end
  end

  ##
  # INC1 instruction
  # Increase given register by 1
  private def inc1(args)
    @regs[args.first] += 1 if args.first.is_a? Symbol
    inc_program_counter
  end

  ##
  # INC2 instruction
  # Increase given register by given value or other register content.
  # Leaves register in +args[1]+ with 0.
  private def inc2(args)
    @regs[args.first] += get_data_from(args[1])
    @regs[args[1]] = 0
    inc_program_counter(3)
  end

  ##
  # INC4 instruction
  # Increase given register by product of
  # - two registers content or
  # - constant number and a register content or
  # - two constant numbers
  # Leaves register in +args[2]+ and +args[3]+ with 0.
  private def inc4(args)
    @regs[args.first] += get_data_from(args[1]) * get_data_from(args[2])
    @regs[args[2]] = 0
    @regs[args[3]] = 0
    inc_program_counter(6)
  end

  ##
  # JNZ instruction
  # Jumps by given offset - can be a register or constant number
  private def jnz(args)
    inc_program_counter(get_data_from(args.first).zero? ? 1 : get_data_from(args[1]))
  end

  ##
  # CPY instruction
  # Copys a register or constant number into another register
  private def cpy(args)
    if args[1].is_a? Symbol
      @regs[args[1]] = get_data_from(args.first)
    end
    inc_program_counter
  end

  ##
  # TGL instruction
  # Toggles the instruction at given offset.
  # If offset is outside the instructions list -> do nothing.
  # Upon toggle we recalculate the optimisations.
  private def tgl(args)
    toggle_idx = @program_counter + get_data_from(args.first)
    unless toggle_idx >= @instructions_toggled.size
      @instructions_toggled[toggle_idx][:cmd] = toggle_command(@instructions_toggled[toggle_idx])
      @instructions = optimize(@instructions_toggled)
    end
    inc_program_counter
  end

  ##
  # Determine the command the given instruciton should be toggled to
  # Increase given register by 1
  private def toggle_command(instr)
    case instr[:args].size
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
      raise "toggle_command: instruction data size '#{instr[:args].size}'"
    end
  end

  ##
  # Increment the program counter by given +val+.
  # Incremented by one in case +val+ omitted.
  private def inc_program_counter(val = 1)
    @program_counter += val
  end

  ##
  # Retrieve data from given identifier.
  # If identifier is a Symbol the content of the matching register is returned.
  private def get_data_from(id)
    id.is_a?(Symbol) ? @regs[id] : id
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
