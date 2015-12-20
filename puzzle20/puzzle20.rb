#!/usr/bin/env ruby
require 'prime'

target = 36_000_000

class Fixnum
  # based on http://stackoverflow.com/questions/3398159/all-factors-of-a-given-number
  def divisors
    primes, powers = prime_division.transpose
    exponents = powers.map { |i| (0..i).to_a }
    divisors = exponents.shift.product(*exponents).map do |powers|
      primes.zip(powers).map { |prime, power| prime**power }.inject(:*)
    end
    divisors.sort
  end
end

pt1_num = nil
pt2_num = nil
divs_usage = {}
num = 2
loop do
  divs = num.divisors
  divs.each do |div|
    divs_usage[div] ||= 0
    divs_usage[div] += 1
  end
  presents1 = divs.map { |f| f * 10 }.reduce(:+)
  presents2 = divs.reject { |d| divs_usage[d] > 50 }.map { |f| f * 11 }.reduce(:+)
  puts "num=#{num}, pres1=#{presents1}, pres2=#{presents2}, pt1_num=#{pt1_num}, pt2_num=#{pt2_num}" if num % 10_000 == 0
  pt1_num = num if presents1 >= target unless pt1_num
  pt2_num = num if presents2 >= target unless pt2_num
  break if pt1_num && pt2_num
  num += 1
end

puts "Puzzle20 Part01: num=#{pt1_num}"
puts "Puzzle20 Part02: num=#{pt2_num}"
