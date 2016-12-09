#!/usr/bin/env ruby

if ARGV.size.zero?
  puts 'Please provide path to input file'
  exit 1
end

RubyVM::InstructionSequence.compile_option = {
  tailcall_optimization: true,
  trace_instruction: false
}

class Decoder
  ZIP_TAG = /\((?<num_chars>\d+)x(?<reps>\d+)\)/

  def initialize(input)
    @input = input
    @remainder = input.clone
    @output = ''
  end

  def decode
    return @output unless @output.size.zero?
    # search till first '(', remove it from input and add to output
    until @remainder.empty?
      zip_tag_begin = @remainder.index('(')
      if zip_tag_begin.nil?
        # no more repetition data
        # append whatever is in remainder and return
        @output << @remainder
        @remainder.clear
        return @output
      end

      # add chars till begin of rep data
      @output << @remainder[0...zip_tag_begin]
      @remainder = @remainder[zip_tag_begin..-1]
      zip_tag_end = @remainder.index(')')
      zip_tag = @remainder[0..zip_tag_end]
      @remainder = @remainder[(zip_tag_end + 1)..-1]
      m = ZIP_TAG.match(zip_tag)
      raise "'#{rep_data}' did not match rep data pattern" unless m

      num_chars = m[:num_chars].to_i
      reps = m[:reps].to_i
      pattern = @remainder[0...num_chars]
      @remainder = @remainder[num_chars..-1]
      @output << pattern * reps
    end
    @output
  end
end

input = open(ARGV[0]).readlines.map(&:strip)
decoded = input.map do |inp|
  Decoder.new(inp).decode.size
end

puts "Puzzle09 Step1: Non-Whitespace in decoded strings: #{decoded.inject(0, &:+)} (should be 102239)"
