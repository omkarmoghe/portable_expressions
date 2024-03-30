# frozen_string_literal: true

module PortableExpressions
  # Used to wrap `operands` when evaluating an `Expression`. This allows us to "extend" the functionality of an object
  # without polluting the app wide definition.
  class Operand < SimpleDelegator
    def and(other)
      __getobj__ && other.__getobj__
    end

    def or(other)
      __getobj__ || other.__getobj__
    end
  end
end
