#!/usr/bin/env ruby

require 'trollop'

opts = Trollop.options do
  version 'AoC:Puzzle15, (c) Florian Oberleitner (florian.oberleitner@gmail.com)'
  opt :input, 'Path to input data', type: String
end
Trollop.die :input, 'required' unless opts[:input]
Trollop.die :input, 'does not exists' unless File.exist?(opts[:input])

#########################################

ingredient_pattern = /(?<name>\w+): capacity (?<capacity>-?\d+), durability (?<durability>-?\d+), flavor (?<flavor>-?\d+), texture (?<texture>-?\d+), calories (?<calories>-?\d+)/

class Ingredient
  def initialize(name, capacity, durability, flavor, texture, calories)
    @name = name
    @capacity = capacity.to_i
    @durability = durability.to_i
    @flavor = flavor.to_i
    @texture = texture.to_i
    @calories = calories.to_i
  end
  attr_reader :capacity, :durability, :flavor, :texture, :calories
end

ingredients = File.readlines(opts[:input]).map do |line|
  fail 'Ingredient did not match' unless ingredient_pattern.match(line)
  m = Regexp.last_match
  Ingredient.new(m[:name], m[:capacity], m[:durability], m[:flavor], m[:texture], m[:calories])
end

# create all valid combos
# TODO: needs to be sped up
possible_amounts = *(1..(101 - ingredients.size))
all_combos = possible_amounts.repeated_permutation(ingredients.size)
valid_combos = all_combos.select { |combo| combo.reduce(:+) == 100 }

scores = valid_combos.each_with_object({ part1: [], part2: [] }) do |combo, memo|
  vals = Array.new(5, 0)
  combo.each_with_index do |amount, index|
    vals[0] += ingredients[index].capacity * amount
    vals[1] += ingredients[index].durability * amount
    vals[2] += ingredients[index].flavor * amount
    vals[3] += ingredients[index].texture * amount
    vals[4] += ingredients[index].calories * amount
  end
  score = vals[0..3].map { |val| val < 0 ? 0 : val }.reduce(:*)
  memo[:part1] << score
  memo[:part2] << score if vals[4] == 500
end

puts "Puzzle15: Part1: max score=#{scores[:part1].max}"
puts "Puzzle15: Part2: max score=#{scores[:part2].max}"
