#!/usr/bin/env ruby

# by reddit user fixed_carbon(https://www.reddit.com/user/fixed_carbon)

def group(addr)
  addr.split(/\[|\]/)
      .zip([0, 1].cycle)
      .sort_by { |_a, i| i }
      .chunk { |_a, i| i }.to_a
      .map { |_ck, ary| ary.map { |str, _num| str } }
end

def checkgroups2(groups)
  out, hyp = groups.map { |g| g.map { |el| getabas(el) }.flatten }
  out.each do |o|
    a, b = o.chars
    return true if hyp.include?(b + a + b)
  end
  false
end

def getabas(str)
  str.chars.each_cons(3).map do |a, b, c|
    a == c && a != b ? [a, b, c].join : nil
  end.compact
end

inp = File.readlines(ARGV[0]).map(&:strip)
puts inp.map { |addr| checkgroups2(group(addr)) }.count(true)
inp.each do |addr|
  puts addr unless checkgroups2(group(addr))
end
