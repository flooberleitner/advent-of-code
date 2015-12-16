#!/usr/bin/env ruby

require 'trollop'

opts = Trollop.options do
  version 'AoC:Puzzle16, (c) Florian Oberleitner (florian.oberleitner@gmail.com)'
  opt :input, 'Path to input data', type: String
end
Trollop.die :input, 'required' unless opts[:input]
Trollop.die :input, 'does not exists' unless File.exist?(opts[:input])

#########################################

sue_pattern = /Sue (\d+):/
item_pattern = /(\w+): (\d+)/

sues = File.readlines(opts[:input]).each_with_object({}) do |line, sues|
  fail 'Sue did not match' unless line.match(sue_pattern)
  num = Regexp.last_match(1).to_i
  sues[num] = line.scan(item_pattern).each_with_object({}) { |m, items| items[m[0].to_sym] = m[1].to_i }
end

mfcsam_result = {
  children: 3,
  cats: 7,
  samoyeds: 2,
  pomeranians: 3,
  akitas: 0,
  vizslas: 0,
  goldfish: 5,
  trees: 3,
  cars: 2,
  perfumes: 1
}

matches = sues.select do |sue, items|
  items.map { |type, amount| mfcsam_result[type] == amount }.all?
end
puts "Puzzle16: Part1: Sue #{matches.keys.first} matched"

matches = sues.select do |sue, items|
  items.map do |type, amount|
    result = mfcsam_result[type]
    case type
    when :cats
      amount > result
    when :trees
      amount > result
    when :pomeranians
      amount < result
    when :goldfish
      amount < result
    else
      amount == result
    end
  end.all?
end
puts "Puzzle16: Part2: Sue #{matches.keys.first} matched"
