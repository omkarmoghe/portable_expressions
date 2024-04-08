# frozen_string_literal: true

class TestLogicalMethods < Minitest::Test
  def setup
    @env = PortableExpressions::Environment.new(
      "variable_true" => true,
      "variable_false" => false
    )
  end

  def test_logical_and
    expression = PortableExpressions::Expression.new(
      :and,
      PortableExpressions::Variable.new("variable_true"),
      PortableExpressions::Variable.new("variable_false")
    )

    assert_equal(false, @env.evaluate(expression))
  end

  def test_logical_or
    expression = PortableExpressions::Expression.new(
      :or,
      PortableExpressions::Variable.new("variable_true"),
      PortableExpressions::Variable.new("variable_false")
    )

    assert(@env.evaluate(expression))
  end
end
