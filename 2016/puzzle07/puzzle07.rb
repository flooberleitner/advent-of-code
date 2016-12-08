#!/usr/bin/env ruby

if ARGV.size.zero?
  puts 'Please provide path to input file'
  exit 1
end

class TLSCounter
  ABBA_PATTERN = /((\w)(\w)\3\2)/

  def initialize
    @valid_count = 0
  end
  attr_reader :valid_count

  def add_string(string)
    @valid_count += 1 if valid?(string)
  end

  def abbas(string)
    string.scan(ABBA_PATTERN).flatten.delete_if do |s|
      s.size == 1 || s.delete(s[0]).size.zero?
    end
  end

  def valid?(string)
    abbas = abbas(string)
    return false if abbas.nil? || abbas.empty?
    abbas.each do |abba|
      return false if string.match("\\[[^\\]]*#{abba}.*?\\]")
    end
    true
  end
end

class SSLCounter
  ABA_PATTERN = /((\w)(\w)\3\2)/

  def initialize
    @valid_count = 0
  end
  attr_reader :valid_count

  def add_string(string)
    @valid_count += 1 if valid?(string)
  end

  def abbas(string)
    string.scan(ABA_PATTERN).flatten.delete_if do |s|
      s.size == 1 || s.delete(s[0]).size.zero?
    end
  end

  def valid?(string)
    abbas = abbas(string)
    return false if abbas.nil? || abbas.empty?
    abbas.each do |abba|
      return false if string.match("\\[[^\\]]*#{abba}.*?\\]")
    end
    true
  end
end

tls = TLSCounter.new
ssl = SSLCounter.new
open(ARGV[0]) do |file|
  file.readlines.each do |line|
    line.strip!
    tls.add_string(line)
    ssl.add_string(line)
  end
end

puts "Puzzle05 Step1: #{tls.valid_count}"
puts "Puzzle05 Step2: #{ssl.valid_count}"
