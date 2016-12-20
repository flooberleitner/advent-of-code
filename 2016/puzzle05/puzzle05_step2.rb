#!/usr/bin/env ruby

require 'digest'

class PasswordFinderStep2
  def initialize(door_id:, length:)
    @door_id = door_id
    @length = length
    @password = Array.new(8)

    search
  end

  private def search
    cnt = -1
    while @password.any?(&:nil?)
      cnt += 1
      if (cnt % 1_000_000).zero?
        puts "\n#{cnt}: #{password}\n"
      elsif (cnt % 20_000).zero?
        print '.'
      end

      cipher = Digest::MD5.hexdigest(@door_id + cnt.to_s)
      next unless cipher[0..4] == '00000'
      pos = cipher[5].ord - 48 # 48 == '0'
      next if pos > (@length - 1)
      next unless @password[pos].nil?
      @password[pos] = cipher[6]
    end
  end

  def password
    @password.each_with_object('') { |c, m| m << (c.nil? ? '_' : c) }
  end
end

step2 = PasswordFinderStep2.new(door_id: 'reyedfim', length: 8)
puts "Puzzle05 Step2: #{step2.password}"
