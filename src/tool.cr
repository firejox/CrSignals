module CrSignals::Tool
  macro included
    {% if @type.name == "<Program>" %}
      private macro cr_signal(call)
        {% verbatim do %}
          {% if call.is_a?(Call) %}
            {% raise "The argument `#{call.id}` has receiver" if call.receiver %}
            {% if @type != "<Program>" %}
              {%
                data = CrSignals::SignalImpl::CDATA
                counter = data[:counter]

                if signals = data[:signals]
                  if call_name_set = signals[@type.id]
                    if call_set = call_name_set[call.name]
                      unless call_set[call.id]
                        call_set[call.id] = {call, counter}
                      else
                        raise "Duplicate signals defined : #{call.id}"
                      end
                    else
                      call_name_set[call.name] = {call.id => {call, counter}}
                    end
                  else
                    signals[@type.id] = {call.name => {call.id => {call, counter}}}
                  end
                else
                  data[:signals] = {@type.id => {call.name => {call.id => {call, counter}}}}
                end

                data[:counter] = counter + 1
              %}

              @__signal_member_{{ counter }} = CrSignals::SignalImpl({{ call.args.splat }}, Nil).new

            {% else %}
              {% raise "`cr_signal` cannot be used in global space." %}
            {% end %}
          {% else %}
            {% raise "The argument `#{call.id}` is not a call statement" %}
          {% end %}
        {% end %}
      end

      private macro cr_slot(call)
        {% verbatim do %}
          def {{ call.id }} : Nil
            {{ yield }}
          end
        {% end %}
      end

      private macro cr_sig_connect(src, src_path, src_call_name, target_call)
        {% verbatim do %}
          {% if target_call.is_a?(Call) || target_call.is_a?(ProcPointer) %}
            {%
              args = target_call.args
              data = CrSignals::SignalImpl::CDATA

              if src_path.is_a?(Generic)
                src_type = src_path.name.resolve
              else
                src_type = src_path.resolve
              end

              if target_call.is_a?(Call)
                call_arg = "->#{target_call.id}".id
              else
                call_arg = target_call.id
              end

              call_name_set = data[:signals][src_type.id][src_call_name.id]
            %}

            {% if call_name_set %}
              {%
                values = call_name_set.values
                code = "CrSignals::SignalImpl.to_nil_return_proc(#{call_arg}) { |call| " +
                       values.map { |v| "#{src.id}.@__signal_member_#{v[1]}.try_connect(call) { " }.join(" ") +
                       "CrSignals::SignalImpl.no_match_proc_signal(call)" + values.map { " } " }.join(" ") +
                       "}"
              %}
              {{ code.id }}
            {% else %}
              {% raise "There is no signal #{src_call_name.id} of type #{src_path.id}" %}
            {% end %}
          {% else %}
            {% raise "Invlaid arguments" %}
          {% end %}
        {% end %}
      end

      private macro cr_sig_disconnect(src, src_path, src_call_name, target_call)
        {% verbatim do %}
          {% if target_call.is_a?(Call) || target_call.is_a?(ProcPointer) %}
            {%
              args = target_call.args
              data = CrSignals::SignalImpl::CDATA

              if src_path.is_a?(Generic)
                src_type = src_path.name.resolve
              else
                src_type = src_path.resolve
              end

              if target_call.is_a?(Call)
                call_arg = "->#{target_call.id}".id
              else
                call_arg = target_call.id
              end

              call_name_set = data[:signals][src_type.id][src_call_name.id]
            %}

            {% if call_name_set %}
              {%
                values = call_name_set.values
                code = "CrSignals::SignalImpl.to_nil_return_proc(#{call_arg}) { |call| " +
                        values.map { |v| "#{src.id}.@__signal_member_#{v[1]}.try_disconnect(call) { " }.join(" ") +
                       "CrSignals::SignalImpl.no_match_proc_signal(call)" + values.map { " } " }.join(" ") +
                       "}"
              %}
              {{ code.id }}
            {% else %}
              {% raise "There is no signal #{src_call_name.id} of type #{src_path.id}" %}
            {% end %}
          {% else %}
            {% raise "Invlaid arguments" %}
          {% end %}
        {% end %}
      end

      private macro cr_sig_emit(src, src_path, src_call_name, *args)
        {% verbatim do %}
          {%
            data = CrSignals::SignalImpl::CDATA

            if src_path.is_a?(Generic)
              src_type = src_path.name.resolve
            else
              src_type = src_path.resolve
            end

            call_name_set = data[:signals][src_type.id][src_call_name.id]
          %}
          
          {% if call_name_set %}
            {%
              values = call_name_set.values
              code = values.map { |v| "#{src.id}.@__signal_member_#{v[1]}.try_emit(#{args.splat}, nil) { " }.join(" ") +
                     "CrSignals::SignalImpl.no_match_argument_type(#{args.splat})" + values.map { " } " }.join(" ")
            %}
            {{ code.id }}
          {% else %}
            {% raise "There is no signal #{src_call_name.id} of type #{src_path.id}" %}
          {% end %} 
        {% end %}
      end

    {% else %}
      {% raise "CrSignals::Tool should be included in global space." %}
    {% end %}
  end
end
