class Spell
  @@effect_method_pattern = /^(?<type>.*)_effect$/

  def initialize(name, costs: 0, effects: [])
    @name = name
    @costs = costs
    @effects = effects
  end
  attr_reader :name, :costs, :effects
end
