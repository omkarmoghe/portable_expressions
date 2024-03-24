module Expressive
  class Expression
    include Serializable

    ALLOWED_OPERANDS = [
      Expression,
      Scalar,
      Variable
    ].freeze

    attr_reader :operator, :operands, :output

    # @param operator [String, Symbol] Mathematical operator to `reduce` the `operands` array with.
    # @param *operands [Variable, Expressions] 2 or more Variables, Scalars, or Expressions
    # @param output [String] The variable to write the expressions output to
    def initialize(operator, *operands, output: nil)
      @operator = operator.to_sym
      @operands = operands
      @output = output

      validate!
    end

    def to_s
      "(#{operands.join(" #{operator.to_s} ")})"
    end

    def as_json
      super.merge(
        operator: operator.to_s,
        operands: operands.map(&:as_json),
        output: output
      )
    end

    private

    def validate!
      raise InvalidOperandError, "Must provide 2 or more operands." unless operands.length >= 2

      unless (operands.map(&:class) - ALLOWED_OPERANDS).empty?
        raise InvalidOperandError, "Operands must be one of #{ALLOWED_OPERANDS.inspect}."
      end

      nil
    end
  end
end
