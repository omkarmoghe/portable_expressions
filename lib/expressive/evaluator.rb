require 'delegate'

module Expressive
  # Used to wrap `operands` when evaluating an `Expression`. This allows us to "extend" the functionality of an object
  # without polluting the app wide definition.
  class Evaluator < SimpleDelegator
    def and(other)
      __getobj__ && other.__getobj__
    end

    def or(other)
      __getobj__ || other.__getobj__
    end
  end
end
