require "./annotations.cr"

module CrSignals::Tool
  macro included
    {% raise "CrSignals::Tool should be included in global space." if @type.name != "<Program>" %}

    private macro cr_signal(call)
      {% verbatim do %}
        {% if call.is_a?(Call) %}
          {% raise "The argument `#{call.id}` has receiver" if call.receiver %}
          {% if @type != "<Program>" %}
            {%
              data = CrSignals::SignalImpl::CDATA
              counter = data[:counter]
              args = call.args

              call_name = call.name.symbolize

              method_set = {call_name => true}

              data[:counter] = counter + 1
            %}

            @[CrSignals::Signal(call: {{ call.name }}, id: {{ counter }})]
            @__signal_member_{{ counter }} = CrSignals::SignalImpl({{ args.splat(",") }} Nil).new

            {% if mod_type = @type.constant("CrSignalSet_SHOULD_NOT_BE_EXPLICITLY_USED") %}
              {% set = mod_type.annotation(CrSignals::Signal).args[0] %}
              {% set[call_name] = true %}
            {% else %}
              @[CrSignals::Signal({{ method_set }})]
              private module CrSignalSet_SHOULD_NOT_BE_EXPLICITLY_USED
              end

              macro finished
                include CrSignals::Generator
              end
            {% end %}
          {% else %}
            {% raise "`cr_signal` cannot be used in global space." %}
          {% end %}
        {% else %}
          {% raise "The argument `#{call.id}` is not a call statement" %}
        {% end %}
      {% end %}
    end
  end
end
