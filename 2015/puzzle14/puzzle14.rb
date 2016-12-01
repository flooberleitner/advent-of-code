#!/usr/bin/env ruby

require 'trollop'

opts = Trollop.options do
  version 'AoC:Puzzle13, (c) Florian Oberleitner (florian.oberleitner@gmail.com)'
  opt :input, 'Path to input data', type: String
end
Trollop.die :input, 'required' unless opts[:input]
Trollop.die :input, 'does not exists' unless File.exist?(opts[:input])

#########################################

class Reindeer
  def initialize(name, speed, endurance, rest)
    @name = name
    @speed = speed.to_i
    @endurance = endurance.to_i
    @rest = rest.to_i
  end

  def distance_after(seconds)
    cycle = @endurance + @rest
    distance = (seconds / cycle).floor * @endurance * @speed
    remainder = seconds % cycle
    distance + (remainder > @endurance ? @endurance : remainder) * @speed
  end
end

reindeer_pattern = /(?<name>\w+) can fly (?<speed>\d+) km\/s for (?<endurance>\d+) seconds, but then must rest for (?<rest>\d+) seconds./

descriptions = File.readlines(opts[:input])

reindeers = descriptions.each_with_object([]) do |descr, memo|
  fail 'Reindeer did not match' unless reindeer_pattern.match(descr)
  m = Regexp.last_match
  memo << Reindeer.new(m[:name], m[:speed], m[:endurance], m[:rest])
end

{
  test_1000: 1000,
  race: 2503
}.each do |key, time|
  points = Array.new(reindeers.size, 0)
  distances = nil
  (1..time).each do |cur_time|
    distances = reindeers.map { |reindeer| reindeer.distance_after(cur_time) }
    distances.each_with_index do |distance, deer_index|
      points[deer_index] += 1 if distance == distances.max
    end
  end
  puts "Puzzle14: #{key}-Part1: #{distances.max}"
  puts "Puzzle14: #{key}-Part2: #{points.max}"
end
