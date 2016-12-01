module Gates
  class Basic
    include ObserveIt::Observable
    include ObserveIt::Observer

    def initialize(name)
      @name = name
      @output = 0xFFFFFFFF
      @inputs = []
    end
    attr_reader :name, :output

    def method_missing(method, *args, &block)
      case method.to_s
      when /input(?<inp>[0-9])*=\z/
        # extract input number
        inp = Regexp.last_match[:inp].to_i
        inp = 0 unless inp
        # define input setter for future use
        define_singleton_method(method) do |input|
          fail ArgumentError, 'input must be kind of Gates::Basic' unless input.kind_of? Gates::Basic
          @inputs[inp].unregister(self) if @inputs[inp]
          @inputs[inp] = input
          @inputs[inp].register(self)
          @output = apply_logic
        end

        # for whatever reason define_singlton_method returns just a Symbol
        # and not the new method as Proc (as state in 2.2.0 doc)
        # -> call defined input setter by hand
        method(method).call(*args)
      when /input(?<inp>[0-9])*\z/
        # extract input number
        inp = Regexp.last_match(:inp).to_i
        inp = 0 unless inp
        # define input getter for future use
        define_singleton_method(method) { @inputs[inp] }
        # call defined input getter by hand
        method(method).call(*args)
      else
        super
      end
    end

    # Expected to return the new output value based on input values and logic
    def apply_logic
      fail 'apply_logic not implemented'
    end

    # if inputs where reassigned this needs to be called when finished
    def inputs_stable
      notify_observers
    end

    def observed_changed
      new_output = apply_logic
      return if @output == new_output
      @output = new_output
      notify_observers
    end
  end

  class Value < Basic
    def output=(value)
      return if value == @output
      @output = value
      notify_observers
    end
  end

  class Connection < Basic
    def apply_logic
      input.output
    end
  end

  class And < Basic
    def apply_logic
      inp1 = input1 ? input1.output : 0xFFFFFFFF
      inp2 = input2 ? input2.output : 0xFFFFFFFF
      inp1 & inp2
    end
  end

  class Or < Basic
    def apply_logic
      inp1 = input1 ? input1.output : 0x00000000
      inp2 = input2 ? input2.output : 0x00000000
      inp1 | inp2
    end
  end

  class Shift < Basic
    attr_accessor :shift

    def apply_logic
      inp = input ? input.output : 0x00000000
      shift = @shift ? @shift : 1
      shift_operation(inp, shift)
    end

    def shift_operation(value, shift)
      fail 'shift_operation not implemented'
    end
  end

  class RShift < Shift
    def shift_operation(value, shift)
      value >> shift
    end
  end

  class LShift < Shift
    def shift_operation(value, shift)
      value << shift
    end
  end

  class Not < Basic
    def apply_logic
      inp = input ? input.output : 0x00000000
      ~inp
    end
  end
end
