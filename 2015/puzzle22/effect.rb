module Effect
  class Base
    def initialize(value: 0, duration: 0)
      @value = value
      @duration = duration
    end
    attr_reader :value, :name, :duration

    def fade(val = 1)
      @duration -= val
    end

    def faded?
      @duration <= 0
    end

    def one_time?
      faded?
    end

    def value_to_apply
      return 0 if faded?
      @value
    end
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
