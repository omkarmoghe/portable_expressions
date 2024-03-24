# frozen_string_literal: true

require_relative "expressive/version"
require_relative "expressive/modules/serializable"
require_relative "expressive/scalar"
require_relative "expressive/variable"
require_relative "expressive/expression"
require_relative "expressive/environment"

module Expressive
  Error = Class.new(StandardError)

  DeserializationError = Class.new(Error)
  InvalidOperandError = Class.new(Error)
  InvalidOperatorError = Class.new(Error)
  MissingVariableError = Class.new(Error)

  # @param json [String, Hash]
  # @return [Expression, Scalar, Variable, Environment]
  def self.from_json(json)
    json = JSON.parse(json) if json.is_a?(String)

    case json["object"]
    when Environment.name
      Environment.new(**json["variables"])
    when Expression.name
      operator = json["operator"].to_sym
      operands_json = json["operands"]
      operands = operands_json.map { |operand_json| from_json(operand_json) }

      Expression.new(operator, *operands)
    when Variable.name
      Variable.new(json["name"])
    when Scalar.name
      Scalar.new(json["value"])
    else
      raise DeserializationError, "Object class #{json["object"]} does not support deserialization."
    end
  rescue JSON::ParserError => e
    raise DeserializationError, "Unable to parse JSON: #{e.message}."
  end
end
