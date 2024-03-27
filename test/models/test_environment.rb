class TestEnvironment < Minitest::Test
  def setup
    @env = PortableExpressions::Environment.new(
      "variable_a" => 1,
      "variable_b" => 2
    )
  end

  def test_evaluate_variables
    assert_equal(1, @env.evaluate(PortableExpressions::Variable.new("variable_a")))
    assert_equal(2, @env.evaluate(PortableExpressions::Variable.new("variable_b")))
  end

  def test_evaluate_missing_variable
    assert_raises(PortableExpressions::MissingVariableError) do
      @env.evaluate(PortableExpressions::Variable.new("missing_variable"))
    end
  end

  def test_scalar
    assert_equal(1, @env.evaluate(PortableExpressions::Scalar.new(1)))
  end

  def test_expression
    expression = PortableExpressions::Expression.new(
      :+,
      PortableExpressions::Variable.new("variable_a"),
      PortableExpressions::Variable.new("variable_b")
    )

    assert_equal(3, @env.evaluate(expression))
  end

  def test_expression_output
    expression = PortableExpressions::Expression.new(
      :+,
      PortableExpressions::Variable.new("variable_a"),
      PortableExpressions::Variable.new("variable_b"),
      output: "variable_c"
    )

    @env.evaluate(expression)
    assert_equal(3, @env.variables["variable_c"])
  end

  def test_expression_update_output
    expression1 = PortableExpressions::Expression.new(
      :+,
      PortableExpressions::Variable.new("variable_a"),
      PortableExpressions::Variable.new("variable_b"),
      output: "variable_a"
    )
    expression2 = PortableExpressions::Expression.new(
      :+,
      PortableExpressions::Variable.new("variable_a"),
      PortableExpressions::Variable.new("variable_b"),
      output: "variable_c"
    )

    @env.evaluate(
      expression1,
      expression2
    )

    assert_equal(3, @env.variables["variable_a"])
    assert_equal(5, @env.variables["variable_c"])
  end
end
