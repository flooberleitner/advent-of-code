class DuetEmulator
  INSTRUCTION_PATTERN = /^(?<cmd>\w+)( (?<arg1>-?[\d\w]+) ?)(?<arg2>-?[\d\w]+)?( *#*.*)?$/
  SUPPORTED_CMDS = %w(add jgz mod mul rcv set snd).freeze

  attr_reader :program, :regs, :last_freq, :cmd_exec_count

  def initialize(name:, source:, queue_in: nil, queue_out: nil)
    @name = name
    @debug = false
    @source = source
    @programm = []
    @program_counter = 0
    @optimizers_enabled = true
    @optimizers = []
    @program = compile(@source)
    @queue_in = queue_in
    @queue_out = queue_out
    @duet_mode = @queue_in && @queue_out
    reset_emulator
  end

  ##
  # Execute already compiled programm or compile given new source and execute.
  # Registers are preloaded with provided values
  def execute(source: nil, reg_init: nil)
    reset_emulator
    @regs.merge! reg_init if reg_init
    @program = compile(source) if source
    @program.each { |i| puts i.inspect } if @debug
    puts "Instruction Count: #{@program.size}" if @debug
    reason = catch :abort_execution do
      while program_counter_valid?
        instr = @program[@program_counter]
        puts "pc=#{@program_counter}, regs=#{@regs.inspect}, instr=#{instr.inspect}" if @debug
        send(instr[:cmd], instr[:args])
      end
      :pc_out_of_range
    end

    case reason
    when :recover
      last_freq
    when :pc_out_of_range
      puts 'Program counter was out of range'
      -1
    else
      -2
    end
  end

  ##
  # Check if current program counter is in range of the program
  def program_counter_valid?
    @program_counter >= 0 && @program_counter < @program.size
  end

  ##
  # Load instructions from source code
  # Returns an array of instructions.
  # In instruction is a hash {cmd: :COMMAND, :args [ARGUMENTS]}
  def compile(source)
    source.map do |line|
      m = line.match(INSTRUCTION_PATTERN)
      raise "Unknown Emulator instruction '#{line}'" unless m
      cmd = m[:cmd]
      raise "Unknown Emulator command '#{cmd}'" unless SUPPORTED_CMDS.include? cmd
      {
        cmd: cmd.to_sym,
        args: [
          convert_instruction_arg(m[:arg1]),
          convert_instruction_arg(m[:arg2])
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
  # Resets the internal state of the emulator
  private def reset_emulator
    @regs = Hash.new(0)
    @cmd_exec_count = Hash.new(0)
    @program_counter = 0
  end

  ##
  # Retrieve data from given identifier.
  # If identifier is a Symbol the content of the matching register is returned.
  private def get_data_from(id)
    id.is_a?(Symbol) ? @regs[id] : id
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
  # Add an optimizer callback that will be executed after all previously added optimizers.
  private def add_optimizer(optimizer)
    @optimizers << optimizer
  end

  ##
  # Increment the program counter.
  # If no step size is given, counter is incremented by 1
  private def incr_program_counter(step_size = 1)
    @program_counter += step_size
  end

  ##
  # Increment number of times the given command was executed
  private def incr_cmd_exec_count(cmd)
    @cmd_exec_count[cmd] += 1
  end

  ##
  # No Operation
  private def nop
    incr_cmd_exec_count(:nop)
    incr_program_counter
  end

  private def add(args)
    incr_cmd_exec_count(:add)
    @regs[args[0]] += get_data_from(args[1])
    incr_program_counter
  end

  private def jgz(args)
    incr_cmd_exec_count(:jgz)
    incr_program_counter(
      get_data_from(args[0]) > 0 ? get_data_from(args[1]) : 1
    )
  end

  private def mod(args)
    incr_cmd_exec_count(:mod)
    @regs[args[0]] = get_data_from(args[0]) % get_data_from(args[1])
    incr_program_counter
  end

  private def mul(args)
    incr_cmd_exec_count(:mul)
    @regs[args[0]] *= get_data_from(args[1])
    incr_program_counter
  end

  # Puzzle01 -> recover, Puzzle02 -> receive
  private def rcv(args)
    incr_cmd_exec_count(:rcv)
    if @duet_mode
      # data = fetch_data_from_partner
      data = @queue_in.pop
      @regs[args[0]] = data
    else
      throw(:abort_execution, :recover) unless get_data_from(args[0]).zero?
    end
    incr_program_counter
  end

  private def set(args)
    incr_cmd_exec_count(:set)
    @regs[args[0]] = get_data_from(args[1])
    incr_program_counter
  end

  # Puzzle01 -> sound, Puzzle02 -> send
  private def snd(args)
    incr_cmd_exec_count(:snd)
    if @duet_mode
      send_data_to_partner(get_data_from(args[0]))
    else
      @last_freq = get_data_from(args[0])
    end
    incr_program_counter
  end

  ##
  # Send data to the partner
  private def send_data_to_partner(data)
    @queue_out << data
  end
end
