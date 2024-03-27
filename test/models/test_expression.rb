class TestExpression < Minitest::Test
  def test_minimum_operands
    assert_raises(PortableExpressions::InvalidOperandError) do
      PortableExpressions::Expression.new(:+, PortableExpressions::Scalar.new(1))
    end
  end

  def test_allowed_operands
    assert_raises(PortableExpressions::InvalidOperandError) do
      PortableExpressions::Expression.new(:+, 1, 2)
    end
  end
end
