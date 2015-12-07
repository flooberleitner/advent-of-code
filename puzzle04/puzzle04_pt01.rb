#!/usr/bin/env ruby -w

require 'digest'
require 'openssl'

secret_key = 'ckczppom'
prefix_pattern = /^00000/

num = 0
digest = nil
loop do
  puts 'Checking: ' + num.to_s if num % 100_000 == 0
  digest = Digest::MD5.hexdigest(secret_key + num.to_s)
  break if prefix_pattern.match(digest)
  num += 1
end

puts 'Puzzle04: First number is: ' + num.to_s
puts 'Puzzle04: Digest was: ' + digest
puts '=================================', '', ''
