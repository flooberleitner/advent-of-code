#!/usr/bin/env ruby

require 'english'

class Processor
  def initialize(to_char: 'p')
    @to_char = to_char
    @instructions = []
    @programms = ('a'..@to_char).to_a
    @history = [memory]
  end

  def compile(instructions)
    instructions.each do |instruction|
      case instruction
      when /^s(?<amount>\d+)$/
        @instructions << {
          cmd: :spin,
          args: [
            $LAST_MATCH_INFO[:amount].to_i
          ]
        }
      when %r{^x(?<pos1>\d+)/(?<pos2>\d+)$}
        @instructions << {
          cmd: :exchange,
          args: [
            $LAST_MATCH_INFO[:pos1].to_i,
            $LAST_MATCH_INFO[:pos2].to_i
          ]
        }
      when %r{^p(?<prog1>\w+)/(?<prog2>\w+)$}
        @instructions << {
          cmd: :partner,
          args: [
            $LAST_MATCH_INFO[:prog1],
            $LAST_MATCH_INFO[:prog2]
          ]
        }
      else
        raise "Instruction '#{instruction}' can not be matched."
      end
    end
  end

  def next(runs: 1)
    runs.times do |run|
      @instructions.each do |instruction|
        send(instruction[:cmd], *instruction[:args])
      end

      if @history.include? memory
        offset = @history.index(memory)
        cycle_size = @history.size - offset
        remaining_runs = runs - run
        return @history[(remaining_runs % cycle_size) + offset - 1]
      else
        @history << memory
      end
    end
    memory
  end

  # rotates the programs by given amount
  # positive amount mean elements moving towards end
  def spin(amount)
    @programms.rotate!(-amount)
  end

  def exchange(pos1, pos2)
    swap = @programms[pos1]
    @programms[pos1] = @programms[pos2]
    @programms[pos2] = swap
  end

  def partner(prog1, prog2)
    exchange(
      @programms.index(prog1),
      @programms.index(prog2)
    )
  end

  def memory
    @programms.join
  end
end

# Declare the number of the AOC17 puzzle
PUZZLE = 16

# Declare all runs to be done for this puzzle
{
  test: {
    skip: false,
    input: 's1,x3/4,pe/b',
    to_char: 'e',
    target1: 'baedc',
    target2: 'abcde'
  },
  puzzle: {
    skip: false,
    input: 'input.txt',
    to_char: 'p',
    target1: 'kpbodeajhlicngmf',
    target2: 'ahgpjdkcbfmneloi'
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
            [run_pars[:input]]
          end.map { |l| l.split(/,/) }.flatten

  processor = Processor.new(to_char: run_pars[:to_char])
  processor.compile(input)

  res1 = processor.next
  success_msg1 = res1 == run_pars[:target1] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name}/1 #{success_msg1}: #{res1} (Target: #{run_pars[:target1]})"

  # TODO for part 2 we have to check when the sequence starts to loop and from
  # there on calculate what would be the state at the 1 billionth repetition
  res2 = processor.next(runs: 999_999_999)
  success_msg2 = res2 == run_pars[:target2] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name}/2 #{success_msg2}: #{res2} (Target: #{run_pars[:target2]})"
  puts '=' * 50
end
