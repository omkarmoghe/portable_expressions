require 'delegate'

module Expressive
  class Evaluator < SimpleDelegator
    def and(other)
      __getobj__ && other.__getobj__
    end

    def or(other)
      __getobj__ || other.__getobj__
    end
  end
end
