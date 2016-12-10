#!/usr/bin/env ruby

if ARGV.size.zero?
  puts 'Please provide path to input file'
  exit 1
end

##
# Base class for entities in the factory
class InputProcessor
  def initialize(id)
    @id = id
    @chips = []
  end
  attr_accessor :id, :chips

  def add_chip(chip)
    @chips << chip
    act_on_new_chip
  end

  def act_on_new_chip
    raise "#{self.class}: Method not implemented"
  end
end

##
# Outputs take do nothing special with chips, they just store them.
class Output < InputProcessor
  def act_on_new_chip
    # Outputs just store the new values
  end
end

##
# Bots wait till they have two chips and then hand them
# over to the next bot based on the set behaviour.
class Bot < InputProcessor
  def initialize(id, specials, notify_on_specials)
    super(id)
    @specials = specials
    @notify_on_specials = notify_on_specials
  end

  def set_behaviour(low_to: nil, high_to: nil)
    @low_to = low_to
    @high_to = high_to
  end

  def act_on_new_chip
    return unless @chips.size > 1
    @low_to.add_chip(@chips.min) if @low_to
    @high_to.add_chip(@chips.max) if @high_to
    check_for_special_vals
    @chips.clear
  end

  def check_for_special_vals
    @notify_on_specials.got_specials(bot: self) if @chips.sort == @specials
  end
end

##
# A Factory represents a collection of bots and outputs that are connected
# to each other and can process input.
class Factory
  INPUT_INSTR = /^value (?<val>\d+) goes to bot (?<bot>\d+)$/
  BEHAV_INSTR = /^^bot (?<id>\d+) gives low to (?<low_type>bot|output) (?<low_id>\d+) and high to (?<high_type>bot|output) (?<high_id>\d+)$$/

  def initialize(setup)
    @bots = []
    @outputs = []
    @specials = [17, 61]
    setup_entities(setup)
  end
  attr_accessor :bots, :outputs

  def setup_entities(setup)
    setup.each do |instr|
      instr.match(BEHAV_INSTR) do |m|
        bot = get_entity('bot', m[:id].to_i)
        low_to = get_entity(m[:low_type], m[:low_id].to_i)
        high_to = get_entity(m[:high_type], m[:high_id].to_i)
        bot.set_behaviour(low_to: low_to, high_to: high_to)
      end
    end
  end

  def process(inputs)
    inputs.each do |input|
      input.match(INPUT_INSTR) do |m|
        get_entity('bot', m[:bot].to_i).add_chip(m[:val].to_i)
      end
    end
  end

  def got_specials(bot:)
    @special_bots ||= []
    @special_bots << bot
  end
  attr_accessor :special_bots

  private def get_entity(type, id)
    if type == 'bot'
      @bots[id] ||= Bot.new(id, @specials, self)
    else
      @outputs[id] ||= Output.new(id)
    end
  end
end

input = open(ARGV[0]).readlines.map(&:strip)
factory = Factory.new(input)
factory.process(input)

puts "Step1: #{factory.special_bots[0].id}"
puts "Step2: #{factory.outputs[0].chips[0] \
               * factory.outputs[1].chips[0] \
               * factory.outputs[2].chips[0]}"
