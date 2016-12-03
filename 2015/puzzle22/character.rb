require_relative 'spell'
require_relative 'effect'

class Character
  def initialize(name, health: 0, hit_points: 0, armor: 0, mana: 0, spells: nil)
    @name = name
    @health = health
    @hit_points = hit_points
    @armor = armor
    @mana = mana
    @spells = spells

    @spell_armor = 0
    @total_costs = 0
    @active_effects = []
  end
  attr_reader :name, :health, :hit_points, :armor, :mana, :total_costs, :active_effects

  def attack(opponent)
    opponent.attacked_by(self)
  end

  def start_round
    apply_effects
    fade_effects
    clear_faded_effects
  end

  def apply_effects
    @active_effects.each do |effect|
      @health += effect.value if effect.is_a?(Effect::Healing)
      @health -= effect.value if effect.is_a?(Effect::Damage)
      @mana += effect.value if effect.is_a?(Effect::ManaRegen)
    end
  end

  def fade_effects
    @active_effects.each { |effect| effect.duration -= 1 }
  end

  def clear_faded_effects
    @active_effects = @active_effects.delete_if do |effect|
      del = effect.duration <= 0
      @spell_armor -= effect.value if del && effect.is_a?(Effect::Armor)
      del
    end
  end

  def cast_a_spell(opponent)
    spell = choose_spell(opponent)
    return unless spell

    puts spell.inspect
    # apply costs
    @mana -= spell.costs
    @total_costs += spell.costs

    # add effects to myself and opponent
    spell.my_effects.each { |effect| add_effect(effect) }
    spell.opponent_effects.each { |effect| opponent.add_effect(effect) }
  end

  def choose_spell(opponent)
    @spells.select do |spell|
      keep = spell.costs <= @mana ? true : false

      if keep && (!@active_effects.empty? || !spell.my_effects.empty?)
        spell_my_effect_classes = spell.my_effects.map(&:class)
        my_active_effect_classes = @active_effects.map(&:class)
        keep = spell_my_effect_classes.none? do |c|
          my_active_effect_classes.include?(c)
        end
      end

      if keep && (!opponent.active_effects.empty? || !spell.opponent_effects.empty?)
        opp_effect_classes = spell.opponent_effects.map(&:class)
        opp_active_effect_classes = opponent.active_effects.map(&:class)
        keep = opp_effect_classes.none? do |c|
          opp_active_effect_classes.include?(c)
        end
      end
      keep
    end.sample
  end

  def add_effect(effect)
    if effect.duration.zero?
      heal(effect.value) if effect.is_a?(Effect::Healing)
      injure(effect.value) if effect.is_a?(Effect::Damage)
      charge(effect.value) if effect.is_a?(Effect::ManaRegen)
    else
      @active_effects << effect.dup
      @spell_armor += effect.value if effect.is_a?(Effect::Armor)
    end
  end

  def heal(value)
    @health += value
  end

  def injure(value)
    @health -= value
    @health = 0 if @health < 0
  end

  def charge(value)
    @mana += value
  end

  def deplete(value) # not really needed
    @mana -= value
    @mana = 0 if @mana < 0
  end

  def alive?
    @health > 0
  end

  def dead?
    !alive?
  end

  def round_start
    apply_spell_effects_for_round
  end

  def round_end
    clear_faded_effects
  end

  def attacked_by(opponent)
    damage = opponent.hit_points - @armor - @spell_armor
    damage = 1 unless damage > 0
    @health -= damage
  end
end
