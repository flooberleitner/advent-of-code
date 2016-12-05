#!/usr/bin/env ruby

require 'digest'

##
# A class for brute forcing passwords according to methods
# provided via test subjects.
# The Brute creates the ciphers and hands them over to each
# subject which then handled the password creation.
class Brute
  def initialize(door_id:)
    @door_id = door_id
    @subjects = []
  end

  ##
  # Adding a subject that gets the created cipher handed over
  # to perform its checks and create the password
  def add_subject(subject)
    @subjects << subject unless @subjects.include?(subject)
  end

  ##
  # Start breaking the passwords
  def break
    # Work with a local copy of the subjects array because we want to
    # stop handling a subject once it finished
    test_subjects = @subjects.clone
    # We loop as long as there is a subject that is not finishd
    round = 0
    while test_subjects.any? { |s| !s.finished? }
      # Create cipher, hand over to each subject and increase round counter
      cipher = Digest::MD5.hexdigest(@door_id + round.to_s)
      test_subjects.each { |s| s.take(cipher) }

      remove_finished(round: round, subjects: test_subjects)
      print_progress(round: round, subjects: test_subjects)

      round += 1
    end
  end

  ##
  # Remove subject from given +subjects+ it is finished
  private def remove_finished(round:, subjects:)
    # only check every so many rounds
    return subjects unless (round % 100_000).zero?
    orig_subjects = subjects.clone
    remaining = subjects.delete_if(&:finished?)
    # Return if nothing was deleted
    return subjects if remaining.size == orig_subjects.size
    # Print deleted items
    puts "\n#{round}:\n"
    (orig_subjects - remaining).each { |s| puts "  FINISHED: #{s.verbose_result}\n" }
    remaining
  end

  ##
  # Just print the progress so far for +round+ and +subjects+
  private def print_progress(round:, subjects:)
    if (round % 1_000_000).zero?
      puts "\n#{round}:\n"
      subjects.each { |s| puts "  #{s.verbose_result}" }
    elsif (round % 10_000).zero?
      print '.'
    end
  end

  ##
  # Return array of string with verbose_result of each subject
  def results
    @subjects.map(&:verbose_result)
  end
end

##
# Base class password mechanism test subject that can be handed
# over to the Brute.
class PasswordMechanism
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
  def take(cipher)
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
  def take(cipher)
    return unless cipher[0..4] == '00000'
    add_char(char: cipher[5], pos: chars_added_count)
  end
end

##
# Implementation of Step2 password mechanism
class Step2 < PasswordMechanism
  def take(cipher)
    return unless cipher[0..4] == '00000'
    pos = cipher[5].ord - 48 # 48 == '0'
    add_char(char: cipher[6], pos: pos)
  end
end

brute = Brute.new(door_id: 'reyedfim')
brute.add_subject(Step1.new(name: 'Step1', pass_length: 8))
brute.add_subject(Step2.new(name: 'Step2', pass_length: 8))

brute.break

puts "\nPuzzle 2016/05 results"
brute.results.each { |r| puts "  #{r}" }
