# frozen_string_literal: true

module Expressive
  # A `Variable` represents a named value stored in the `Environment`. Unlike `Scalars`, `Variables` have no value
  # until they are evaluated by an `Environment`. Evaluating a `Variable` that isn't present in the `Environment` will
  # result in a `MissingVariableError`.
  class Variable
    include Serializable

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def to_s
      name
    end

    def as_json
      super.merge(
        name: name
      )
    end
  end
end
