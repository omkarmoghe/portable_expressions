# frozen_string_literal: true

module Expressive
  # A `Scalar` is the simplest object that can be evaluated. It holds a single `value`. When used in an `Expression`,
  # this `value` must respond to the symbol (i.e. support the method) defined by the `Expression#operator`.
  class Scalar
    include Serializable

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_s
      value.to_s
    end

    def as_json
      super.merge(
        value: value
      )
    end
  end
end
