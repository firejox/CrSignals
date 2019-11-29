module CrSignals
  # :nodoc:
  struct SignalImpl(*T)
    CDATA = {:counter => 0}

    def initialize
      @slots = Set(Proc(*T)).new
    end

    def connect(proc : Proc(*T))
      @slots.add(proc)
    end

    def disconnect(proc : Proc(*T))
      @slots.delete(proc)
    end

    def emit(*args : *T)
      {% if T.size == 1 %}
        @slots.each &.call
      {% else %}
        @slots.each(&.call(args[0]
          {% for i in 1...(T.size - 1) %}
            ,args[{{ i }}]
          {% end %}
        ))
      {% end %}
    end

    def clear
      @slots.clear
    end

    def try_connect(proc : Proc(*T), &block)
      connect(proc)
    end

    def try_connect(other)
      yield
    end

    def try_disconnect(proc : Proc(*T), &block)
      disconnect(proc)
    end

    def try_disconnect(other)
      yield
    end

    def try_emit(*args : *T, &block)
      emit(*args)
    end

    def try_emit(*args)
      yield
    end

    def self.no_match_argument_type(*args : *T)
      {% raise "There is no match signal for the argument (#{T.type_vars.splat})" %}
    end

    def self.no_match_proc_signal(proc : Proc(*T))
      {% raise "There is no match signal for the proc restriction Proc(#{T.type_vars.splat})" %}
    end
  end
end
