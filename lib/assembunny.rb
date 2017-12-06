#!/usr/bin/env ruby

##
# History:
#  2016/23 Part 2 takes far too long to run
#   -> transpile to C?
#   -> also think about what does the Assembunny code do, not just instruction
#      by instruction but in whole blocks of instructions
#      Maybe some parts can be optimized by introducing new instructions?
#
# Another ides: p_tseng wrote an optimiser for Assembunny code
#   -> https://www.reddit.com/r/adventofcode/comments/5jvbzt/2016_day_23_solutions/dbje1ik/
#   => look at that and maybe get some ideas about how a pro does it

##
# Assembunny Emulator implementation.
# 2016/23 part 2 took faaaaar too long to run
# There was also the hint to make some optimisations
# -> took a look at the code and also some of the solutions
# p_tseng implemented a clever optimiser which was inspiration for the
# optimizer part (https://www.reddit.com/r/adventofcode/comments/5jvbzt/2016_day_23_solutions/dbje1ik/)
class AssembunnyEmulator
  INSTRUCTION_PATTERN = /^(?<cmd>\w+)( (?<d1>-?[\d\w]+) ?)(?<d2>-?[\d\w]+)?( *#*.*)?$/

  def initialize(source: nil)
    @debug = false
    @instructions = []
    @optimizer_enabled = true
    @optimizers = []
    add_optimizer :optimize_inc_by_mul
    add_optimizer :optimize_inc_by
    reset_emulator
    load(source) if source
  end
  attr_reader :regs, :cycles, :instructions

  ##
  # Execute the provided Assembunny sourcecode.
  # Register bank is initialized with given values.
  def execute(source: nil, reg_init: {})
    reset_emulator
    @regs.merge! reg_init
    load(source) if source
    @instructions.each { |i| puts i.inspect } if @debug
    puts "Instruction Count: #{@instructions.size}" if @debug
    while @program_counter < @instructions.size
      @cycles += 1
      instr = @instructions[@program_counter]
      puts "#{@cycles}: pc=#{@program_counter}, regs=#{@regs.inspect}, instr=#{instr.inspect}" if @debug
      begin
        send(instr[:cmd], instr[:args])
      rescue AbortExecutionError
        break
      end
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
  # Enable instruction optimizer
  def enable_optimizer
    @optimizer_enabled = true
    optimize_instructions
  end

  ##
  # Disable instruction optimizer
  def disable_optimizer
    @optimizer_enabled = false
    @instructions = @instructions_toggled.map { |i| i.dup.freeze }.freeze
  end

  ##
  # Add an optimizer callback that will be executed after all previously added optimizers.
  def add_optimizer(optimizer)
    @optimizers << optimizer
  end

  ##
  # Run the optimizations and replace current instruction list to optimized list
  def optimize_instructions
    return unless @optimizer_enabled
    @instructions = optimize(@instructions_toggled)
  end

  ##
  # Retrieve data from given identifier.
  # If identifier is a Symbol the content of the matching register is returned.
  private def get_data_from(id)
    id.is_a?(Symbol) ? @regs[id] : id
  end

  ##
  # Resets the internal state of the emulator
  private def reset_emulator
    @regs = Hash.new(0)
    @program_counter = 0
    @cycles = 0
  end

  ##
  # Load instructions from source code
  # Returns an array of instructions.
  # In instruction is a hash {cmd: :COMMAND, :args [ARGUMENTS]}
  private def load(source)
    @instructions_original = source.map do |line|
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

    @instructions_toggled = @instructions_original.map(&:dup)
    optimize_instructions
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
    @optimizers.each { |o| send(o, optimized) }

    optimized.freeze
  end

  ##
  # Optimize inc_by pattern in place in +instructions+
  private def optimize_inc_by(instructions)
    # Sequence
    #   inc a
    #   dec c
    #   jnz c -2
    # is a 'a += c' which can be expressed as a 2 arg inc 'inc a, c'
    # leaving c with 0.
    pattern_size = 3
    instructions.each_cons(pattern_size).with_index do |(i1, i2, i3), idx|
      next unless i1[:cmd] == :inc &&
                  i2[:cmd] == :dec &&
                  i3[:cmd] == :jnz &&
                  i2[:args].first == i3[:args].first && i3[:args][1] == -2
      instructions[idx] = {
        cmd: :inc_by_opt,
        args: [
          i1[:args].first,
          i2[:args].first,
          3
        ].freeze
      }.freeze
      (pattern_size - 1).times do |i|
        instructions[idx + 1 + i] = { cmd: :nop, args: [].freeze }.freeze
      end
    end
  end

  ##
  # Optimize inc_by pattern in place in +instructions+.
  private def optimize_inc_by_mul(instructions)
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
    pattern_size = 6
    instructions.each_cons(pattern_size).with_index do |(i1, i2, i3, i4, i5, i6), idx|
      next unless i1[:cmd] == :cpy &&
                  i2[:cmd] == :inc &&
                  i3[:cmd] == :dec &&
                  i4[:cmd] == :jnz &&
                  i5[:cmd] == :dec &&
                  i6[:cmd] == :jnz &&
                  i3[:args].first == i4[:args].first && i4[:args][1] == -2 &&
                  i5[:args].first == i6[:args].first && i6[:args][1] == -5
      instructions[idx] = {
        cmd: :inc_by_mul_opt,
        args: [
          i2[:args].first,
          i1[:args].first,
          i5[:args].first,
          i1[:args][1],
          6
        ].freeze
      }.freeze
      (pattern_size - 1).times do |i|
        instructions[idx + 1 + i] = { cmd: :nop, args: [].freeze }.freeze
      end
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
  # Increase given register by 1
  private def inc(args)
    @regs[args.first] += 1 if args.first.is_a? Symbol
    inc_program_counter
  end

  ##
  # INC_BY instruction
  # Increase given register by given value or other register content.
  # Leaves register in +args[1]+ with 0.
  private def inc_by_opt(args)
    @regs[args.first] += get_data_from(args[1])
    @regs[args[1]] = 0
    inc_program_counter(args.last)
  end

  ##
  # INC_BY_MUL instruction
  # Increase given register by product of
  # - two registers content or
  # - constant number and a register content or
  # - two constant numbers
  # Leaves register in +args[2]+ and +args[3]+ with 0.
  private def inc_by_mul_opt(args)
    @regs[args.first] += get_data_from(args[1]) * get_data_from(args[2])
    @regs[args[2]] = 0
    @regs[args[3]] = 0
    inc_program_counter(args.last)
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
    @regs[args[1]] = get_data_from(args.first) if args[1].is_a? Symbol
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
      optimize_instructions
    end
    inc_program_counter
  end

  ##
  # Determine the command the given instruciton should be toggled to
  # Increase given register by 1
  private def toggle_command(instr)
    # do not toggle optimized commands
    return instr[:cmd] if instr[:cmd] =~ /^.+_opt$/

    # toggle depends on number of arguments
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
  # Can be raised by a command handler to abort execution in emulator
  class AbortExecutionError < StandardError
  end
end
