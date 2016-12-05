#!/usr/bin/env ruby

require 'digest'

class PasswordFinderStep1
  def initialize(door_id:, length:)
    @door_id = door_id
    @length = length
    @password = ''

    search
  end
  attr_reader :password

  private def search
    cnt = 0
    loop do
      cipher = Digest::MD5.hexdigest(@door_id + cnt.to_s)
      password << cipher[5] if cipher[0..4] == '00000'
      break if password.length >= @length
      cnt += 1
      puts "#{cnt}: #{@password}" if cnt % 100_000 == 0
    end
  end
end

puts 'Calculating Step 1'
step1 = PasswordFinderStep1.new(door_id: 'reyedfim', length: 8)
puts "Puzzle05 Step1: #{step1.password}"
