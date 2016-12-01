#!/usr/bin/env ruby

require_relative './characters'
require_relative './spells'
require_relative './effects'

class Game
  @@spells = [
    Spell.new(:magic_missile, costs: 53, effects: [Effects::Damage.new(value: 4)]),
    Spell.new(:drain, costs: 73, effects: [Effects::Damage.new(value: 2), Effects::Healing.new(value: 2)]),
    Spell.new(:shield, costs: 113, effects: [Effects::Armor.new(value: 7, duration: 6)]),
    Spell.new(:poison, costs: 173, effects: [Effects::Damage.new(value: 3, duration: 6)]),
    Spell.new(:recharge, costs: 229, effects: [Effects::ManaRegen.new(value: 101, duration: 5)])
  ]

  def initialize
    @boss = Character.new('Boss', health: 55, attack: 8)
    @player = Character.new('Player', health: 50, mana: 500)
    @rng = Random.new
  end

  def do_round
    spell = select_spell(@boss.active_effects)
  end

  def finished?
    return false if @boss.alive? && @player.alive?
    true
  end

  def select_spell(active_effects)
    active_effects = active_effects.map(&:class).uniq
    loop do
      spell = @@spells[@rng.rand(@@spells.size)]
      return spell unless spell.effects.map(&:class).uniq.any? { |e| active_effects.include?(e) }
    end
  end
end

game = Game.new
10.times { game.do_round }
puts game.finished?
