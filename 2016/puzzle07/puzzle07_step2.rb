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
    @valid_ip_count += 1 if valid?(ip)
  end

  def tokens_in(ip)
    ip.scan(@token_pattern).flatten.delete_if do |s|
      s.size == 1 || s.delete(s[0]).size.zero?
    end
  end

  def valid?(ip)
    raise 'Method not implemented'
  end
end

class TLSHandler < BaseIPHandler
  def initialize
    super(token_pattern: /((\w)(\w)\3\2)/)
  end

  def valid?(ip)
    tokens = tokens_in(ip)
    return false if tokens.nil? || tokens.empty?
    tokens.each do |token|
      return false if ip =~ /\[[^\]]*#{token}.*?\]/
    end
    true
  end
end

class SSLHandler < BaseIPHandler
  def initialize
    super(token_pattern: /(?=((?:(\w)([^\[\]])\2).*(?:\3\2\3)))/)
  end

  def valid?(ip)
    tokens = tokens_in(ip)

    # return false if tokens.nil? || tokens.empty?
    if tokens.nil? || tokens.empty?
      puts ip
      return false
    end

    tokens.each do |token|
      # tokens have the ABA and BAB at begin/end
      # If we strip all letters just the square brackets remain.
      # If the result of brackets is empty, both ABA and BAB where
      # in the same block.
      # If even size, this means that both ABA and BAB, are either inside or
      # outside brackets.
      # If we have an odd number ob bracket this means that one of ABA
      # or BAB was inside and the other one outside the brackets.
      # Remark: size '0' returns false for odd?
      return true if token.tr('a-z', '').size.odd?
    end
    # puts ip
    # puts tokens.inspect
    # puts remains
    puts ip
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

puts "Puzzle05 Step1: #{tls.valid_ip_count}"
puts "Puzzle05 Step2: #{ssl.valid_ip_count} (Should return 231)"

# After comparison to result of fixed_carbon (compared the denied IPs) the
# offending IP is
# 'pmfxjpcflryhzywdx[yrzzkvweeyrywjvryr]xjsgrxggxetihbhiy[vrrgrojjtbwngsz]wibtryrkfmduzjzadwe'
# in line 1345 in the input file.
# The regex /(?=((?:(\w)([^\[\]])\2).*?(?:\3\2\3)))/ was lacy and the IP had
# two BAB tokens of which the first one does not fulfill the requirements.

# Matching against a lacy regex and a greedy one is also no solution because
# in case there are 3 BABs the middle one would not be matched but could be
# the one fulfilling the requirements.

# In case I match against a greedy regex the IP
# 'kftupspkougaaglay[vvwrbrdwspsiapielt]xgwsbslmoxgdsps' in line 593 is an
# offender.

# => Should scan for tokens inside/outside brackets and then match them against
#    each other.
