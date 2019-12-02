require "./annotations.cr"

module CrSignals::Tool
  macro included
    {% if @type.name != "<Program>" %}
      {% raise "CrSignals::Tool should be included in global space." %}
    {% end %}
  end

  private macro crs_generate_signal_method(method_name)
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
            signal_name = @def.name[8..-1]
          %}

          {% if data[:error] %}
            {% @def.name.raise "#{@type.id} has no match signal #{signal_name}(#{U.type_vars.splat}) to disconnect." %}
          {% end %}
        {% end %}
      {% end %}
    end
  end

  private macro crs_signal_check_and_gen_method(method_name)
    {%
      data = CrSignals::SignalImpl::CDATA
      method_exist = false
      if signals = data[:signals]
        method_exist = @type.ancestors.any? { |t| signals[t.id] && signals[t.id][method_name.id] }
      end
    %}

    {% unless method_exist %}
      crs_generate_signal_method({{ method_name }})
    {% end %}
  end

  private macro cr_signal(call)
    {% if call.is_a?(Call) %}
      {% raise "The argument `#{call.id}` has receiver" if call.receiver %}
      {% if @type != "<Program>" %}
        crs_signal_check_and_gen_method({{ call.name }})
        {%
          data = CrSignals::SignalImpl::CDATA
          counter = data[:counter]
          args = call.args

          if args.empty?
            call_id = call.name
          else
            call_id = call.id
          end

          if signals = data[:signals]
            if call_name_set = signals[@type.id]
              if call_set = call_name_set[call.name]
                unless call_set[call_id]
                  call_set[call_id] = counter
                else
                  raise "Duplicate signals defined : #{call.id}"
                end
              else
                call_name_set[call.name] = {call_id => counter}
              end
            else
              signals[@type.id] = {call.name => {call_id => counter}}
            end
          else
            data[:signals] = {@type.id => {call.name => {call_id => counter}}}
          end

          data[:counter] = counter + 1
        %}

        @[CrSignals::Signal(call: {{ call.name }}, id: {{ counter }})]
        @__signal_member_{{ counter }} = CrSignals::SignalImpl({{ call.args.splat(",") }} Nil).new
      {% else %}
        {% raise "`cr_signal` cannot be used in global space." %}
      {% end %}
    {% else %}
      {% raise "The argument `#{call.id}` is not a call statement" %}
    {% end %}
  end
end
