require_relative 'spell'
require_relative 'effect'
require_relative 'log'

class Character
  def initialize(name, health: 0, hit_points: 0, armor: 0, mana: 0,
                 spells: nil, spell_sequence: nil)
    @name = name
    @health = health
    @hit_points = hit_points
    @armor = armor
    @mana = mana
    @spells = spells
    @spell_sequence = spell_sequence
    @spell_armor = 0
    @total_costs = 0
    @active_effects = []
    @spells_casted = []
    @round = 0
    @rng = Random.new
  end
  attr_reader :name, :health, :hit_points, :mana, :total_costs, :active_effects, :spells_casted

  def start_round
    @round += 1
    MyLogger.log.info("Starting round for '#{@name}'") if MyLogger.log?
    apply_effects
    clear_faded_effects
  end

  def end_round
    # MyLogger.log.info("Ending round for '#{@name}'")
  end

  def cast_spell_on(opponent)
    if dead?
      MyLogger.log.warn("'#{@name}' can not cast spell on '#{opponent.name}'" \
                        " because '#{@name}' is dead.") if MyLogger.log?
      return
    end
    MyLogger.log.debug("'#{@name}' cast spell on '#{opponent.name}'")

    spell = select_next_spell(opponent)
    return unless spell

    MyLogger.log.debug("  Got spell '#{spell.name}'") if MyLogger.log?
    # apply costs
    @mana -= spell.costs
    @total_costs += spell.costs

    # add effects to myself and opponent
    spell.my_effects.each { |effect| add_effect(effect) }
    spell.opponent_effects.each { |effect| opponent.add_effect(effect) }
  end

  def add_effect(effect)
    MyLogger.log.debug("Adding effect to '#{@name}'")
    if effect.one_time?
      MyLogger.log.debug("   '#{effect.class}' with immediate effect") if MyLogger.log?
      heal(effect.value) if effect.is_a?(Effect::Healing)
      injure(effect.value) if effect.is_a?(Effect::Damage)
      charge(effect.value) if effect.is_a?(Effect::ManaRegen)
    else
      MyLogger.log.debug("   '#{effect.class}' for duration '#{effect.duration}'") if MyLogger.log?
      @active_effects << effect.dup
      @spell_armor += effect.value if effect.is_a?(Effect::Armor)
    end
  end

  def attack(opponent)
    if dead?
      MyLogger.log.warn("'#{@name}' can not attack '#{opponent.name}'" \
                        " because '#{@name}' is dead.") if MyLogger.log?
      return
    end
    MyLogger.log.debug("'#{@name}' attack '#{opponent.name}'") if MyLogger.log?
    opponent.attacked_by(self)
  end

  def attacked_by(opponent)
    hit_points = opponent.hit_points - @armor - @spell_armor
    hit_points = 1 unless hit_points > 0
    injure(hit_points)
  end

  def alive?
    @health > 0
  end

  def dead?
    !alive?
  end

  def armor
    @armor + @spell_armor
  end

  private def apply_effects
    MyLogger.log.debug("Applying effects for '#{@name}'") if MyLogger.log?
    @active_effects.each do |effect|
      MyLogger.log.debug("  #{effect.class}") if MyLogger.log?
      heal(effect.value_to_apply) if effect.is_a?(Effect::Healing)
      injure(effect.value_to_apply) if effect.is_a?(Effect::Damage)
      replenish(effect.value_to_apply) if effect.is_a?(Effect::ManaRegen)
      effect.fade
      MyLogger.log.debug("  '#{effect.class}': duration left = #{effect.duration}") if MyLogger.log?
    end
  end

  private def clear_faded_effects
    MyLogger.log.debug("Clearing faded effects for '#{@name}'") if MyLogger.log?
    @active_effects = @active_effects.delete_if do |effect|
      del = effect.faded?
      @spell_armor -= effect.value if del && effect.is_a?(Effect::Armor)
      MyLogger.log.debug("  '#{effect.class}' cleared") if  MyLogger.log? && del
      del
    end
  end

  private def select_next_spell(opponent)
    spell = if @spell_sequence && !@spell_sequence.empty?
              @spells[@spell_sequence.delete_at(0)]
            else
              choose_spell(opponent)
            end
    @spells_casted << [spell.name, @round] if spell
    spell
  end

  private def choose_spell(opponent)
    MyLogger.log.debug('Choose spell')

    available_spells = @spells.select do |name, spell|
      MyLogger.log.debug("  Checking spell '#{name}'") if MyLogger.log?
      keep = spell.costs <= @mana ? true : false
      MyLogger.log.debug("    #{keep ? 'Can' : 'Can\'t'} afford it (mana:#{@mana}, costs:#{spell.costs})") if MyLogger.log?

      if keep && !@active_effects.empty? && !spell.my_effects.empty?
        MyLogger.log.debug('    Checking for my effects') if MyLogger.log?
        spell_my_effect_classes = spell.my_effects.map(&:class)
        my_active_effect_classes = @active_effects.map(&:class)
        MyLogger.log.debug("      from spell: #{spell_my_effect_classes}") if MyLogger.log?
        MyLogger.log.debug("       my active: #{my_active_effect_classes}") if MyLogger.log?
        keep = spell_my_effect_classes.none? do |c|
          my_active_effect_classes.include?(c)
        end
      end

      if keep && !opponent.active_effects.empty? && !spell.opponent_effects.empty?
        MyLogger.log.debug('    Checking for opponent effects') if MyLogger.log?
        spell_opp_effect_classes = spell.opponent_effects.map(&:class)
        opp_active_effect_classes = opponent.active_effects.map(&:class)
        MyLogger.log.debug("      from spell: #{spell_opp_effect_classes}") if MyLogger.log?
        MyLogger.log.debug("      opp active: #{opp_active_effect_classes}") if MyLogger.log?
        keep = spell_opp_effect_classes.none? do |c|
          opp_active_effect_classes.include?(c)
        end
      end
      MyLogger.log.debug("  #{keep ? 'Keep' : 'Drop'} '#{spell.name}'") if MyLogger.log?
      keep
    end

    # Prefere some spells as pure random seems to not lead to the right
    # result in reasonable time.
    return available_spells[:recharge] if (@mana <= 250) && available_spells.include?(:recharge)
    # return available_spells[:shield] if available_spells.include?(:shield)
    # return available_spells[:drain] if available_spells.include?(:drain)
    return nil if available_spells.empty?
    available_spells[available_spells.keys.sample(random: @rng)]
  end

  private def heal(value)
    MyLogger.log.debug("Healing '#{@name}' with #{value}") if MyLogger.log?
    @health += value
  end

  private def injure(value)
    MyLogger.log.debug("Injure '#{@name}' with #{value}") if MyLogger.log?
    @health -= value
    @health = 0 if @health < 0
  end

  private def replenish(value)
    MyLogger.log.debug("Charge mana of '#{@name}' with #{value}") if MyLogger.log?
    @mana += value
  end

  private def deplete(value) # not really needed
    MyLogger.log.debug("Deplete mana of '#{@name}' with #{value}") if MyLogger.log?
    @mana -= value
    @mana = 0 if @mana < 0
  end
end
