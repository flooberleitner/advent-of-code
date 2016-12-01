#!/usr/bin/env ruby

class Character
  def initialize(name, health, damage = 0, armor = 0)
    @name = name
    @health = health
    @damage = damage
    @armor = armor
    @costs_of_gear = 0
  end
  attr_reader :name, :health, :damage, :armor, :costs_of_gear

  def add_item(item)
    @damage += item.damage
    @armor += item.armor
    @costs_of_gear += item.costs
  end

  def attack(opponent)
    opponent.attacked_by(self)
  end

  def attacked_by(opponent)
    damage = opponent.damage - @armor
    damage = 1 unless damage > 0
    @health -= damage
  end

  def alive?
    @health > 0
  end
end

class Item
  def initialize(name, costs, damage = 0, armor = 0)
    @name = name
    @costs = costs
    @damage = damage
    @armor = armor
  end
  attr_reader :name, :costs, :damage, :armor
end

weapons = [
  Item.new('Dagger',      8,    4, 0),
  Item.new('Shortsword',  10,   5, 0),
  Item.new('Warhammer',   25,   6, 0),
  Item.new('Longsword',   40,   7, 0),
  Item.new('Greataxe',    74,   8, 0)
]

armor = [
  Item.new('Leather',     13,   0, 1),
  Item.new('Chainmail',   31,   0, 2),
  Item.new('Splintmail',  53,   0, 3),
  Item.new('Bandedmail',  75,   0, 4),
  Item.new('Platemail',   102,  0, 5)
]

rings = [
  Item.new('Damage +1',   25,   1, 0),
  Item.new('Damage +2',   50,   2, 0),
  Item.new('Damage +3',   100,  3, 0),
  Item.new('Defense +1',  20,   0, 1),
  Item.new('Defense +2',  40,   0, 2),
  Item.new('Defense +3',  80,   0, 3)
]

# Item limits
# - at least one weapon
# - armor is optional but 1 max
# - rings are optional but 2 max
# weapons straight forward
item_combinations = weapons.map { |o| [o] }
# weapons with armor
item_combinations.concat weapons.product(armor)
# weapons with 1 ring
item_combinations.concat weapons.product(rings)
# weapons with 2 rings
weapons.each_with_object(item_combinations) do |weapon, memo|
  rings.combination(2).each_entry do |ring_combo|
    memo << (ring_combo << weapon)
  end
end
# weapons with armor and 1/2 rings
weapons.product(armor).each_with_object(item_combinations) do |wa, memo|
  rings.each { |ring| memo << (wa.clone << ring) }
  rings.combination(2).each_entry do |ring_combo|
    memo << wa.clone.concat(ring_combo)
  end
end

costs = { win: [], lose: [] }
item_combinations.each_with_object(costs) do |items, memo|
  boss = Character.new('Boss', 104, 8, 1)
  player = Character.new('Player', 100)
  items.each { |i| player.add_item(i) }

  loop do
    player.attack(boss)
    break unless boss.alive?
    boss.attack(player)
    break unless player.alive?
  end

  if player.alive?
    memo[:win] << player.costs_of_gear
  else
    memo[:lose] << player.costs_of_gear
  end
end

puts "Puzzle21: Part1: lowest winning costs: #{costs[:win].min}"
puts "Puzzle21: Part2: highest losing costs: #{costs[:lose].max}"
