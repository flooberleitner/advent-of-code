require_relative 'effect'
require_relative 'log'

module Spells
  class Spell
    def initialize(name, costs: 0, my_effects: [], opponent_effects: [])
      @name = name
      @costs = costs
      @my_effects = my_effects
      @opponent_effects = opponent_effects
    end
    attr_reader :name, :costs, :my_effects, :opponent_effects
  end

  @spells = [
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

  class << self
    def available_spells
      @spells
    end
  end
end
