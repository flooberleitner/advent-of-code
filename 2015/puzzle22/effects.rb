module Effects
  class Base
    def initialize(value: 0, duration: 0)
      @value = value
      @duration = duration
    end
    attr_reader :value, :duration
  end

  class Damage < Base
  end

  class Armor < Base
  end

  class Healing < Base
  end

  class ManaRegen < Base
  end
end
