require_relative './spells'
require_relative './effects'

class Character
  def initialize(name, health: 0, attack: 0, armor: 0, mana: 0)
    @name = name
    @health = health
    @attack = attack
    @armor = armor
    @mana = mana
    @spell_armor = 0
    @costs_of_gear = 0
    @costs_of_spells = 0
    @active_effects = {}
  end
  attr_reader :name, :health, :damage, :armor, :costs_of_gear, :mana

  def attack(opponent)
    opponent.attacked_by(self)
  end

  def apply_spell_to(opponent, spell)
    # enough mana left?
    return nil if spell.costs > @mana

    # do not apply th spell if one of the effects is already in use
    active_eff_classes = opponent.active_effects.map(&:class).uniq
    spell_eff_classes = spell.effects.map(&:class).uniq
    return nil if spell_eff_classes.any? { |e| active_eff_classes.include?(e) }

    # apply the costs
    @mana -= spell.costs
    @costs_of_spells += spell.costs

    # apply effects to myself
    spell.effects.each do |effect|
      case effect
      when Effects::Healing then apply_effect(effect)
      when Effects::Damage then opponent.apply_effect(effect)
      when Effects::Armor then apply_effect(effect)
      when Effects::ManaRegen then apply_effect(effect)
      else
        fail "Effect '#{effect.class}' not handled"
      end
    end
  end

  def alive?
    @health > 0
  end

  def active_effects
    @active_effects.keys
  end

  def round_start
    apply_spell_effects_for_round
  end

  def round_end
    clear_faded_effects
  end

  private

  def apply_effect(effect)
    if effect.duration == 0
      @health += effect.value if effect.is_a?(Effects::Healing)
      @health -= effect.value if effect.is_a?(Effects::Damage)
    else
      @active_effects[effect] = 0
      @spell_armor += effect.value if effect.is_a?(Effects::Armor)
    end
  end

  def attacked_by(opponent)
    damage = opponent.attack - @armor - @spell_armor
    damage = 1 unless damage > 0
    @health -= damage
  end

  def apply_spell_effects_for_round
    @active_effects.keys.each do |effect|
      @active_effects[effect] += 1

      @health += effect.value if effect.is_a?(Effects::Healing)
      @health -= effect.value if effect.is_a?(Effects::Damage)
      @mana += effect.value if effect.is_a?(Effects::ManaRegen)
    end
  end

  def clear_faded_effects
    @active_effects = @active_effects.delete_if do |effect, active|
      del = active >= effect.duration
      @spell_armor -= effect.value if effect.is_a?(Effects::Armor) if del
      del
    end
  end
end
