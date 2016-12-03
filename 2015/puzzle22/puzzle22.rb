#!/usr/bin/env ruby

require_relative 'character'
require_relative 'spell'
require_relative 'effect'

class Game
  @@spells = [
    Spell.new(
      :magic_missile,
      costs: 53,
      opponent_effects: [Effect::Damage.new(value: 4)]
    ),
    Spell.new(
      :drain,
      costs: 73,
      my_effects: [Effect::Healing.new(value: 2)],
      opponent_effects: [Effect::Damage.new(value: 2)]
    ),
    Spell.new(
      :shield,
      costs: 113,
      my_effects: [Effect::Armor.new(value: 7, duration: 6)]
    ),
    Spell.new(
      :poison,
      costs: 173,
      opponent_effects: [Effect::Damage.new(value: 3, duration: 6)]
    ),
    Spell.new(
      :recharge,
      costs: 229,
      my_effects: [Effect::ManaRegen.new(value: 101, duration: 5)]
    )
  ]

  def initialize(max_costs: nil)
    # @boss = Character.new('Boss', health: 55, hit_points: 8)
    # @player = Character.new('Player', health: 50, mana: 500, spells: @@spells)
    @boss = Character.new('Boss', health: 14, hit_points: 8)
    @player = Character.new('Player', health: 10, mana: 250, spells: @@spells)
    @max_costs = max_costs
    @round = 0
    @costs = nil
  end
  attr_reader :round

  def play
    @round = 1
    while @boss.alive? && @player.alive?
      @boss.start_round
      @player.start_round

      if @round.odd?
        @boss.attack(@player)
      else
        @player.cast_a_spell(@boss)
      end
      @round += 1

      break if @player.total_costs >= @max_costs
    end

    return @player.total_costs if @player.alive?
    nil
  end
end

costs = 1_000_000
5.times do |i|
  print i if (i % 10_000).zero?
  print '.' if (i % 1000).zero?
  game = Game.new(max_costs: costs)
  new_costs = game.play
  costs = new_costs if new_costs && new_costs < costs
end
puts '', costs