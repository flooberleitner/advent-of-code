#!/usr/bin/env ruby

require 'digest'
require_relative '../lib/hash_brute'

##
# Base class password mechanism test subject that can be handed
# over to the Brute.
class PasswordMechanism
  include HashBrute::BaseSubject

  def initialize(name:, pass_length:)
    @name = name
    @pass_length = pass_length
    @password = '_' * pass_length
    @chars_added_count = 0
  end
  attr_accessor :password, :pass_length, :chars_added_count

  ##
  # Take the cipher and mangle it according to implementation.
  # To be implemented by implementation class.
  def take(digest:, index:)
    raise "#{self.class} did not implemente method 'try'"
  end

  ##
  # Return string with verbose print of result.
  def verbose_result
    "#{@name} yielded password '#{@password}'"
  end

  ##
  # Add a character to the password.
  # +char+ is only added at +pos+ if position valid and empty.
  def add_char(char:, pos:)
    return unless pos < @pass_length && @password[pos] == '_'
    @password[pos] = char
    @chars_added_count += 1
  end

  ##
  # True if password generation finished.
  def finished?
    @chars_added_count >= @pass_length
  end
end

##
# Implementation of Step1 password mechanism
class Step1 < PasswordMechanism
  def take(digest:, index:)
    return unless digest[0..4] == '00000'
    add_char(char: digest[5], pos: chars_added_count)
  end
end

##
# Implementation of Step2 password mechanism
class Step2 < PasswordMechanism
  def take(digest:, index:)
    return unless digest[0..4] == '00000'
    pos = digest[5].ord - 48 # 48 == '0'
    add_char(char: digest[6], pos: pos)
  end
end

brute = HashBrute.new(
  salt: 'reyedfim',
  print_progress_every: 500_000,
  check_finished_every: 100_000
)
part1 = Step1.new(name: 'Step1', pass_length: 8)
brute.add_subject(part1)
part2 = Step2.new(name: 'Step2', pass_length: 8)
brute.add_subject(part2)

brute.run

puts "\nPuzzle 2016/05 results"
puts "  #{part1.verbose_result} (corr: f97c354d)"
puts "  #{part2.verbose_result} (corr: 863dde27)"
