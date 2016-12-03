class Spell
  def initialize(name, costs: 0, my_effects: [], opponent_effects: [])
    @name = name
    @costs = costs
    @my_effects = my_effects
    @opponent_effects = opponent_effects
  end
  attr_reader :name, :costs, :my_effects, :opponent_effects
end
