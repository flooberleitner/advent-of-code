#!/usr/bin/env ruby -w

require 'digest'
require 'openssl'

def search_num(secret_key, prefix_pattern)
  num = 0
  digest = nil
  print 'Checking...'
  loop do
    print '.' if num % 100_000 == 0
    print num.to_s if num % 500_000 == 0
    digest = Digest::MD5.hexdigest(secret_key + num.to_s)
    break if prefix_pattern.match(digest)
    num += 1
  end
  puts ''
  return num, digest
end

secret_key = 'ckczppom'

num, digest = search_num(secret_key, /^00000/)
puts "Puzzle04 Pt01: First number is: #{num} (#{digest})"
num, digest = search_num(secret_key, /^000000/)
puts "Puzzle04 Pt02: First number is: #{num} (#{digest})"
