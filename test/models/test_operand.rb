# frozen_string_literal: true

class TestOperand < Minitest::Test
  def test_and
    operands = [PortableExpressions::Operand.new(true), PortableExpressions::Operand.new(true)]
    assert(operands.reduce(:and))
  end

  def test_or
    operands = [PortableExpressions::Operand.new(true), PortableExpressions::Operand.new(false)]
    assert(operands.reduce(:or))
  end
end
