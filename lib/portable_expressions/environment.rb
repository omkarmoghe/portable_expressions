# frozen_string_literal: true

module PortableExpressions
  # The `Environment` holds state in the form of a `variables` hash and can evaluate `Expressions`, `Scalars`, and
  # `Variables` within a context.
  class Environment
    include Serializable

    attr_reader :variables

    # @param variables [Hash]
    def initialize(**variables)
      @variables = variables
    end

    # Evaluates each object. Returns the value of the last object
    # @param objects [Expression, Variable, Scalar] 1 or more object to evaluate.
    def evaluate(*objects)
      objects.map { |object| evaluate_one(object) }.last
    end

    def as_json
      super.merge(variables: variables)
    end

    private

    def evaluate_one(object) # rubocop:disable Metrics/MethodLength
      case object
      when Scalar
        object.value
      when Variable
        variables.fetch(object.name) do |key|
          raise MissingVariableError, "Environment missing variable #{key}."
        end
      when Expression
        value = object.operands
                      .map { |operand| Evaluator.new(evaluate(operand)) }
                      .reduce(object.operator)

        variables[object.output] = value if object.output

        value
      end
    end
  end
end
