#!/usr/bin/env ruby

require_relative 'character'
require_relative 'spell'
require_relative 'effect'
require_relative 'log'

class Game
  def initialize(player:, boss:, max_costs: nil)
    @player = player
    @boss = boss
    @max_costs = max_costs
    @round = 0
  end
  attr_reader :round, :player

  def play
    MyLogger.log.debug("\n===== Starting Game =====\n") if MyLogger.log?
    @round = 1
    while @boss.alive? && @player.alive?
      MyLogger.log.debug("Starting Round #{@round} (player:#{@player.health}/#{@player.armor}/#{@player.mana}, boss:#{@boss.health})") if MyLogger.log?
      @boss.start_round
      @player.start_round

      @player.cast_spell_on(@boss) if @round.odd?
      @boss.attack(@player) if @round.even?

      @boss.end_round
      @player.end_round

      MyLogger.log.debug("Ending Round #{@round} (player:#{@player.health}/#{@player.armor}/#{@player.mana}, boss:#{@boss.health})\n") if MyLogger.log?

      if @player.total_costs >= @max_costs
        MyLogger.log.debug("  Break play because costs exceeded (#{@player.total_costs} >= #{@max_costs})") if MyLogger.log?
        break
      end
      @round += 1
    end
  end

  def costs
    @player.total_costs
  end

  def player_won?
    @player.alive? && @boss.dead?
  end

  def draw?
    (@player.alive? && @boss.alive?) || (@player.dead? && @boss.dead?)
  end
end

MyLogger.log.level = MyLogger::WARN

game = Game.new(
  boss: Character.new(
    'Boss',
    health: 13,
    hit_points: 8
  ),
  player: Character.new(
    'Player',
    health: 10,
    mana: 250,
    spells: Spells.available_spells,
    spell_sequence: [:poison, :magic_missile]
  ),
  max_costs: 1_000_000
)
game.play
puts "Puzzle22 - Example1: costs: #{game.costs}, player_won: #{game.player_won?}"

game = Game.new(
  boss: Character.new(
    'Boss',
    health: 14,
    hit_points: 8
  ),
  player: Character.new(
    'Player',
    health: 10,
    mana: 250,
    spells: Spells.available_spells,
    spell_sequence: [:recharge, :shield, :drain, :poison, :magic_missile]
  ),
  max_costs: 1_000_000
)
game.play
puts "Puzzle22 - Example2: costs: #{game.costs}, player_won: #{game.player_won?}"
puts game.player_won?

MyLogger.log.level = MyLogger::INFO

minimum_costs = 1_000_000
round_achieved = 0
round_count = 0
won = 0
lost = 0
draw = 0
1_000_000.times do |i|
  print "\n#{i}(#{minimum_costs}(#{round_achieved}), won:#{won}, lost:#{lost}, draw:#{draw})" if (i % 10_000).zero?
  print '.' if (i % 1000).zero?
  game = Game.new(
    boss: Character.new(
      'Boss',
      health: 55,
      hit_points: 8
    ),
    player: Character.new(
      'Player',
      health: 50,
      mana: 500,
      spells: Spells.available_spells
    ),
    max_costs: minimum_costs
  )
  game.play
  if game.player_won? && game.costs < minimum_costs
    minimum_costs = game.costs
    round_achieved = i
    round_count = game.round
  end
  won += 1 if game.player_won?
  lost += 1 unless game.player_won?
  draw += 1 if game.draw?

  MyLogger.log.info("Round #{i}: Won with spells: #{game.player.spells_casted.inspect}") if game.player_won?
end
puts "\nPuzzle22 Step1: MinCosts: #{minimum_costs}(#{round_count}), won:#{won}, lost:#{lost}, draw:#{draw}"
