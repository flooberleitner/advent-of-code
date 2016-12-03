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
  attr_reader :round

  def play
    @round = 1
    while @boss.alive? && @player.alive?
      MyLogger.log.info("Starting Round #{@round} (player:#{@player.health}, boss:#{@boss.health})")
      @boss.start_round
      @player.start_round

      @player.cast_spell_on(@boss) if @round.odd?
      @boss.attack(@player) if @round.even?

      @round += 1

      MyLogger.log.debug("Round #{@round}: boss.dead?=#{@boss.dead?}, player.dead?=#{@player.dead?}")
      break if @player.total_costs >= @max_costs
    end
  end

  def costs
    @player.total_costs
  end

  def player_won?
    @player.alive? && @boss.dead?
  end
end

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

minimum_costs = 1_000_000
round_achieved = 0
# 1_000_000.times do |i|
0.times do |i|
  print "\n#{i}(#{minimum_costs} @#{round_achieved})" if (i % 10_000).zero?
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
    round_achieved = game.round
  end
end
puts "\nPuzzle22 Step1: MinCosts: #{minimum_costs} in round #{round_achieved}"
