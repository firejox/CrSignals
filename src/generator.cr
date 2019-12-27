require "./annotations"

module CrSignals::Generator
  private macro cr_signal(call)
    {% raise "The argument `#{call.id}` is not a call statement" unless call.is_a?(Call) %}
    {% raise "The argument `#{call.id}` has receiver" if call.receiver %}

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

    {% if set = @type.constant("ImplicitCrSignalSetWithoutUserUsed") %}
      {% set[call.name] = true %}
    {% else %}
      private ImplicitCrSignalSetWithoutUserUsed = { {{ call.name }}: true }
    {% end %}
  end

  macro included
    {% raise "CrSignals::Generator should not be included in global space." if @type.name == "<Program>" %}

    macro finished
      {% verbatim do %}
        {% set = @type.constant("ImplicitCrSignalSetWithoutUserUsed") %}

        {% for method_name in set.keys %}
          def {{ method_name.id }}(*args : *U) forall U
            {% verbatim do %}
              {% begin %}
                {%
                  signal_name = @def.name
                  vars = @type.instance_vars
                    .select { |v| (x = v.annotation(CrSignals::Signal)) && x[:call].id == signal_name }
                    .sort_by { |v| v.annotation(CrSignals::Signal)[:id] }

                  code = vars.map { |v| "@#{v.name}.try_emit(*args, nil) {" }.join(" ") +
                         "CrSignals::SignalImpl.set_error " +
                         vars.map { "}" }.join(" ")
                %}

                {{ code.id }}
              {% end %}

              {% begin %}
                {%
                  data = CrSignals::SignalImpl::CDATA
                  signal_name = @def.name
                %}

                {% if data[:error] %}
                  {% @def.name.raise "#{@type.id} has no match signal #{signal_name}(#{U.type_vars.splat}) to emit" %}
                {% end %}
              {% end %}
            {% end %}
          end

          def connect_{{ method_name.id }}(proc : *U ->) forall U
            {% verbatim do %}
              {% begin %}
                {%
                  signal_name = @def.name[8..-1]
                  vars = @type.instance_vars
                    .select { |v| (x = v.annotation(CrSignals::Signal)) && x[:call].id == signal_name }
                    .sort_by { |v| v.annotation(CrSignals::Signal)[:id] }

                  code = vars.map { |v| "@#{v.name}.try_connect(proc) {" }.join(" ") +
                         "CrSignals::SignalImpl.set_error " +
                         vars.map { "}" }.join(" ")
                %}

                {{ code.id }}
              {% end %}

              {% begin %}
                {%
                  data = CrSignals::SignalImpl::CDATA
                  signal_name = @def.name[8..-1]
                %}

                {% if data[:error] %}
                  {% @def.name.raise "#{@type.id} has no match signal #{signal_name}(#{U.type_vars.splat}) to connect." %}
                {% end %}
              {% end %}
            {% end %}
          end

          def disconnect_{{ method_name.id }}(proc : *U ->) forall U
            {% verbatim do %}
              {% begin %}
                {%
                  signal_name = @def.name[11..-1]
                  vars = @type.instance_vars
                    .select { |v| (x = v.annotation(CrSignals::Signal)) && x[:call].id == signal_name }
                    .sort_by { |v| v.annotation(CrSignals::Signal)[:id] }

                  code = vars.map { |v| "@#{v.name}.try_disconnect(proc) {" }.join(" ") +
                         "CrSignals::SignalImpl.set_error " +
                         vars.map { "}" }.join(" ")
                %}

                {{ code.id }}
              {% end %}

              {% begin %}
                {%
                  data = CrSignals::SignalImpl::CDATA
                  signal_name = @def.name[11..-1]
                %}

                {% if data[:error] %}
                  {% @def.name.raise "#{@type.id} has no match signal #{signal_name}(#{U.type_vars.splat}) to disconnect." %}
                {% end %}
              {% end %}
            {% end %}
          end
        {% end %}
      {% end %}
    end
  end
end
