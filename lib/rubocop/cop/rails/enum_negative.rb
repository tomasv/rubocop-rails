# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop looks for enums with values prefixed with `not_`.
      #
      # Since Rails 6 for each enum value there's a negated scope
      # generated with a `not_` prefix in front. Defining enum values
      # with `not_` in front can lead to situations where the scope
      # will get overriden by these auto-generated negated scopes.
      #
      # @example
      #   # bad
      #   enum status: { active: 0, not_active: 1, sometimes_active: 2 }
      #
      #   # good
      #   enum status: { active: 0, inactive: 1, sometimes_active: 2 }
      #
      class EnumNegative < Cop
        MSG = 'Enum contains values starting with `not_`. Avoid using `not_*` named enum values.'

        def_node_matcher :enum?, <<~PATTERN
          (send nil? :enum (hash $...))
        PATTERN

        def_node_matcher :array_pair?, <<~PATTERN
          (pair $_ $array)
        PATTERN

        def on_send(node)
          enum?(node) do |pairs|
            pairs.each do |pair|
              key, array = array_pair?(pair)
              next unless key

              add_offense(array, message: format(MSG, enum: enum_name(key)))
            end
          end
        end

        def autocorrect(node)
          hash = node.children.each_with_index.map do |elem, index|
            "#{source(elem)} => #{index}"
          end.join(', ')

          ->(corrector) { corrector.replace(node.loc.expression, "{#{hash}}") }
        end

        private

        def enum_name(key)
          case key.type
          when :sym, :str
            key.value
          else
            key.source
          end
        end

        def source(elem)
          case elem.type
          when :str
            elem.value.dump
          when :sym
            elem.value.inspect
          else
            elem.source
          end
        end
      end
    end
  end
end
