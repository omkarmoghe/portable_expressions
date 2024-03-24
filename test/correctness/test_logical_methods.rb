class TestLogicalMethods < Minitest::Test
  def setup
    @env = Expressive::Environment.new(
      "variable_true" => true,
      "variable_false" => false
    )
  end

  def test_logical_and
    expression = Expressive::Expression.new(
      :and,
      Expressive::Variable.new("variable_true"),
      Expressive::Variable.new("variable_false")
    )

    assert_equal(false, @env.evaluate(expression))
  end

  def test_logical_or
    expression = Expressive::Expression.new(
      :or,
      Expressive::Variable.new("variable_true"),
      Expressive::Variable.new("variable_false")
    )

    assert(@env.evaluate(expression))
  end
end
