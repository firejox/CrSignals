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
      {% begin %}
        @slots.each(&.call({{ (0...(T.size - 1)).map { |i| "args[#{i}]".id }.splat }}))
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

    def self.set_error
      {%
        data = CrSignals::SignalImpl::CDATA
        data[:error] = true
      %}
    end
  end
end
