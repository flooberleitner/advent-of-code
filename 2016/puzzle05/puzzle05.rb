#!/usr/bin/env ruby

require 'digest'

class Brute
  def initialize(door_id:)
    @door_id = door_id
    @subjects = []
    @round = 0
  end

  def add_subject(subject)
    @subjects << subject unless @subjects.include?(subject)
  end

  def break
    test_subjects = @subjects.clone
    while test_subjects.any? { |s| !s.finished? }
      cipher = Digest::MD5.hexdigest(@door_id + @round.to_s)
      test_subjects.each { |way| way.try(cipher) }
      @round += 1

      if (@round % 1_000_000).zero?
        puts "\n#{@round}:\n"
        test_subjects.delete_if do |s|
          fin = s.finished?
          puts "  FINISHED: #{s.verbose_result}" if fin
          fin
        end
        test_subjects.each { |s| puts "  #{s.verbose_result}" }
      elsif (@round % 10_000).zero?
        print '.'
      end
    end
  end

  def results
    @subjects.map(&:verbose_result)
  end
end

class PasswordMechanism
  def initialize(name:, pass_length:)
    @name = name
    @pass_length = pass_length
    @password = '_' * pass_length
    @chars_added_count = 0
  end
  attr_accessor :password, :pass_length, :chars_added_count

  def try(cipher)
    raise "#{self.class} did not implemente method 'try'"
  end

  def verbose_result
    "#{@name} yielded password '#{@password}'"
  end

  def add_char(char:, pos:)
    return unless pos < @pass_length && @password[pos] == '_'
    @password[pos] = char
    @chars_added_count += 1
  end

  def finished?
    @chars_added_count >= @pass_length
  end
end

class Step1 < PasswordMechanism
  def try(cipher)
    return unless cipher[0..4] == '00000'
    add_char(char: cipher[5], pos: chars_added_count)
  end
end

class Step2 < PasswordMechanism
  def try(cipher)
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
