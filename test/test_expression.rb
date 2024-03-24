class TestExpression < Minitest::Test
  def test_minimum_operands
    assert_raises(Expressive::InvalidOperandError) do
      Expressive::Expression.new(:+, Expressive::Scalar.new(1))
    end
  end

  def test_allowed_operands
    assert_raises(Expressive::InvalidOperandError) do
      Expressive::Expression.new(:+, 1, 2)
    end
  end
end
