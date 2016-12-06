#!/usr/bin/env ruby

if ARGV.size.zero?
  puts 'Please provide path to input file'
  exit 1
end

class CharCounter
  def count(char)
    @chars ||= Hash.new(0)
    @chars[char] += 1
  end

  def most_common
    return '_' unless @chars
    @chars.sort_by(&:last).last.first
  end

  def least_common
    return '_' unless @chars
    @chars.sort_by(&:last).first.first
  end
end

class WordHandler
  def add(word)
    @length ||= word.length
    if word.length != @length
      raise "Size of word to add (#{word}) does not match length of first word."
    end
    @char_counters ||= Array.new(@length) { CharCounter.new }
    word.length.times { |pos| @char_counters[pos].count(word[pos]) }
  end

  def decode_most_common
    return '' unless @char_counters
    @char_counters.map(&:most_common).join
  end

  def decode_least_common
    return '' unless @char_counters
    @char_counters.map(&:least_common).join
  end
end

handler = WordHandler.new
open(ARGV[0]) do |file|
  file.readlines.each do |line|
    handler.add(line.strip)
  end
end

puts "Puzzle06 Step1: #{handler.decode_most_common}"
puts "Puzzle06 Step2: #{handler.decode_least_common}"
