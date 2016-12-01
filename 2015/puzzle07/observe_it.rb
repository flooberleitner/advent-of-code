module ObserveIt
  module Observable
    def register(obj)
      observers << obj unless observers.member?(obj) if obj
    end

    def unregister(obj)
      observers.delete(obj)
    end

    def notify_observers
      observers.each(&:observed_changed)
    end

    def observers
      @observers ||= []
    end
  end

  module Observer
    def observed_changed
      fail 'Observer did not implement observed_changed'
    end
  end
end
