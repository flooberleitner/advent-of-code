#!/usr/bin/env ruby

if ARGV.size.zero?
  puts 'Please provide path to input file'
  exit 1
end

class BaseIPHandler
  def initialize(token_pattern:)
    @token_pattern = Regexp.new(token_pattern)
    @valid_ip_count = 0
  end
  attr_reader :valid_ip_count

  def add_ip(ip)
    tokens = net_tokens(ip)
    return if tokens[:supernet].nil? || tokens[:supernet].empty?
    @valid_ip_count += 1 if valid?(tokens)
  end

  def net_tokens(ip)
    nets = ip.split(/\[|\]/)
    toks = { supernet: [], hypernet: [] }
    nets.each_with_index do |net, idx|
      if idx.even?
        toks[:supernet].concat tokens(net)
      else
        toks[:hypernet].concat tokens(net)
      end
    end
    toks
  end

  def tokens(string)
    string.scan(@token_pattern).flatten.delete_if do |t|
      t.size < 3 || t.delete(t[0]).size.zero?
    end
  end

  def valid?(tokens)
    raise 'Method not implemented'
  end
end

class TLSHandler < BaseIPHandler
  def initialize
    super(token_pattern: /((\w)(\w)\3\2)/)
  end

  def valid?(tokens)
    return false unless tokens[:hypernet].empty?
    true
  end
end

class SSLHandler < BaseIPHandler
  def initialize
    super(token_pattern: /(?=((?:(\w)([^\[\]])\2)))/)
  end

  def valid?(tokens)
    tokens[:supernet].each do |aba|
      a, b = aba.chars
      return true if tokens[:hypernet].include?([b, a, b].join)
    end
    false
  end
end

tls = TLSHandler.new
ssl = SSLHandler.new
open(ARGV[0]) do |file|
  file.readlines.each do |line|
    line.strip!
    tls.add_ip(line)
    ssl.add_ip(line)
  end
end

puts "Puzzle05 Step1: #{tls.valid_ip_count} (Should be 115)"
puts "Puzzle05 Step2: #{ssl.valid_ip_count} (Should be 231)"
