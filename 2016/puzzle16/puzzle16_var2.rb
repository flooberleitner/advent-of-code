#!/usr/bin/env ruby

# The sequence of disk fill will be for an initial of '10011' be
# 10011X00110X10011Y11001...
# Which is condensed SXRXSYRXSXRY...
# S...The original sequence
# X...The chain char '0'
# R...The original sequence reversed and inverted
# Y...The chain char inverted (== '1')
#
# -> this means we only need to generate the sequence of chain chars
# and the S/R-sequences can be added when the disk fill is processed
# for the checksum, as it is always S R S R S R
# Probably there is also a pattern behind the fill char sequence but
# I did not get it :)
class DiskFill
  def initialize(initial:, disk_size:, checksum_processor:)
    @initial = initial
    @initial_rev = initial.reverse.tr('10', '01')
    @disk_size = disk_size
    @checksum_processor = checksum_processor
  end

  def run
    chain_seq = chain_char_seq
    chain_seq_offset = 0
    total_count = 0
    until total_count >= @disk_size
      tmp = ''
      slice = chain_seq.slice(chain_seq_offset...(chain_seq_offset + 64))
      chain_seq_offset += 64
      slice.size.times do |idx|
        tmp << (idx.even? ? @initial : @initial_rev)
        tmp << slice[idx]
      end
      remaining = @disk_size - total_count
      tmp = tmp.slice(0...remaining) if remaining <= tmp.size
      total_count += tmp.size
      @checksum_processor.consume(tmp)
    end
  end

  private def chain_char_seq
    puts '== chain_char_seq'
    count = (@disk_size.to_f / (@initial.size + 1)).ceil
    seq = '0'
    while seq.size < count
      seq << '0'
      seq << seq[0..-2].reverse.tr('10', '01')
    end
    puts "chain_char_seq done: size=#{seq.size}, count=#{count}"
    seq[0..count]
  end
end

class ChecksumProcessor
  def initialize(expected_count:)
    @input_expected = expected_count
    @input_consumed = 0
    @stages = setup_stages(expected_count)
  end

  def setup_stages(total_size)
    (0...stage_count(total_size)).each_with_object([]) do |idx, memo|
      memo << Stage.new
      (memo[idx - 1].followup = memo[idx]) if idx > 0
    end
  end

  def stage_count(total_size)
    stage_count = 0
    while total_size.even?
      stage_count += 1
      total_size /= 2
    end
    stage_count
  end

  def consume(input)
    @input_consumed += input.size
    if @input_consumed > @input_expected
      raise "More chars consumed (#{@input_consumed}) "\
            "than expected (#{@input_expected})"
    end
    if (@input_consumed % 50_000).zero?
      puts "Checksum consumed: #{@input_consumed}"
    end
    @stages.first.consume(input)
  end

  def result
    @stages.last.out
  end

  class Stage
    def initialize
      @in = ''
      @out = ''
      @followup = nil
    end
    attr_writer :followup
    attr_reader :out

    def consume(input)
      # return if input.size.zero?
      @in << input
      input.clear
      while @in.size >= 2
        sub = @in.slice!(0..1)
        case sub
        when '00' then @out << '1'
        when '11' then @out << '1'
        when '01' then @out << '0'
        when '10' then @out << '0'
        else
          raise "Unknown pattern '#{sub}'"
        end
      end

      @followup.consume(@out) if @followup
    end
  end
end

test_input = '110010110100'
test_checksum = ChecksumProcessor.new(expected_count: test_input.size)
test_checksum.consume(test_input)
puts "Test Checksum: #{test_checksum.result} (corr: 100)"

part1_checksum = ChecksumProcessor.new(expected_count: 272)
part1_df = DiskFill.new(
  initial: '11110010111001001',
  disk_size: 272,
  checksum_processor: part1_checksum
)
part1_df.run
puts "Puzzle16 Part 1: #{part1_checksum.result} "\
     '(corr: 01110011101111011)'

part2_checksum = ChecksumProcessor.new(expected_count: 35_651_584)
part2_df = DiskFill.new(
  initial: '11110010111001001',
  disk_size: 35_651_584,
  checksum_processor: part2_checksum
)
part2_df.run
puts "Puzzle16 Part 2: #{part2_checksum.result} "\
     '(corr: 11001111011000111)'
