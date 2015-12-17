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
  attr_reader :name, :capacity, :durability, :flavor, :texture, :calories

  def mixtures(overall_igredients,
    used_ingredients = [],
    total_amount = 0,
    previous_mixture = { cap: 0, dur: 0, fla: 0, tex: 0, cal: 0 })

    used_ingredients << self
    all_mixtures = (1..(100 - total_amount)).each_with_object([]) do |amount, mixtures|
      mixture = previous_mixture.clone
      mixture[:cap] += @capacity * amount
      mixture[:dur] += @durability * amount
      mixture[:fla] += @flavor * amount
      mixture[:tex] += @texture * amount
      mixture[:cal] += @calories * amount
      remaining_ingredients = overall_igredients - used_ingredients
      if remaining_ingredients.empty?
        mixtures << mixture
      else
        mixtures << remaining_ingredients.first.mixtures(
          overall_igredients,
          used_ingredients.clone << self,
          total_amount + amount,
          mixture).flatten
      end
    end
    used_ingredients.delete(self)
    all_mixtures.flatten
  end
end

ingredients = File.readlines(opts[:input]).map do |line|
  fail 'Ingredient did not match' unless ingredient_pattern.match(line)
  m = Regexp.last_match
  Ingredient.new(m[:name], m[:capacity], m[:durability], m[:flavor], m[:texture], m[:calories])
end

all_mixtures = ingredients.first.mixtures(ingredients)

scores = all_mixtures.each_with_object({ part1: [], part2: [] }) do |mixture, memo|
  score = mixture.values[0..3].map { |val| val < 0 ? 0 : val }.reduce(:*)
  memo[:part1] << score
  memo[:part2] << score if mixture[:cal] == 500
end

puts "Puzzle15: Part1: max score=#{scores[:part1].max}"
puts "Puzzle15: Part2: max score=#{scores[:part2].max}"
