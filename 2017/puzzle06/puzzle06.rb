#!/usr/bin/env ruby

class Memory
  def initialize(banks)
    @banks = banks.clone
    @states = {}
    @first_state = hash_state(@banks)
    @cycles_needed = 0
  end
  attr_reader :cycles_needed

  def reallocate
    cycle = 0
    loop do
      @states[hash_state(@banks)] = cycle

      bank_ptr = BankPointer.new(
        start: @banks.find_index(@banks.max),
        bank_num: @banks.size
      )

      memory_to_relocate = @banks[bank_ptr.val]
      @banks[bank_ptr.val] = 0
      until memory_to_relocate.zero?
        bank_ptr.incr
        @banks[bank_ptr.val] += 1
        memory_to_relocate -= 1
      end

      cycle += 1

      if @states.key? hash_state(@banks)
        @cycles_needed = cycle - @states[hash_state(@banks)]
        break
      end
    end
    self
  end

  def num_states
    @states.size
  end

  private def hash_state(banks)
    banks.join('_').to_sym
  end
end

class BankPointer
  def initialize(start: 0, bank_num: 16)
    @val = start
    @bank_num = bank_num
    self
  end
  attr_reader :val

  def incr
    @val += 1
    @val %= @bank_num
  end
end

# Declare the number of the AOC17 puzzle
PUZZLE = 6

# Declare all runs to be done for this puzzle
{
  test: {
    input: 'input_test.txt',
    target1: 5,
    target2: 4
  },
  puzzle: {
    input: 'input.txt',
    target1: 11_137,
    target2: 1_037
  }
}.each do |name, pars|
  # skip run?
  if pars[:skip]
    puts "Skipped '#{name}'"
    next
  end

  # open input data and process it
  open(pars[:input]) do |input|
    # Read all input lines and sanitize
    data = input.readlines.map(&:strip)

    # Process data
    banks = data.first.split(/\D/).map { |m| m.empty? ? nil : m.strip.to_i }.compact
    mem = Memory.new(banks)
    mem.reallocate
    res1 = mem.num_states
    res2 = mem.cycles_needed

    # Print result
    success_msg1 = res1 == pars[:target1] ? 'succeeded' : 'failed'
    success_msg2 = res2 == pars[:target2] ? 'succeeded' : 'failed'
    puts "AOC17-#{PUZZLE}/#{name}1 #{success_msg1}: #{res1} (Target: #{pars[:target1]})"
    puts "AOC17-#{PUZZLE}/#{name}2 #{success_msg2}: #{res2} (Target: #{pars[:target2]})"
  end
end
