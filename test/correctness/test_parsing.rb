# frozen_string_literal: true

class TestParser < Minitest::Test
  def test_variable
    json = <<~JSON
      {
        "object": "PortableExpressions::Variable",
        "name": "score_a"
      }
    JSON

    result = PortableExpressions.from_json(json)

    assert_kind_of(PortableExpressions::Variable, result)
    assert_equal("score_a", result.name)
  end

  def test_scalar
    json = <<~JSON
      {
        "object": "PortableExpressions::Scalar",
        "name": "10",
        "value": 10
      }
    JSON

    assert_kind_of(PortableExpressions::Scalar, PortableExpressions.from_json(json))
  end

  def test_expression
    json = <<~JSON
      {
        "object": "PortableExpressions::Expression",
        "operator": "-",
        "operands": [
          {
            "object": "PortableExpressions::Variable",
            "name": "rating_b"
          },
          {
            "object": "PortableExpressions::Variable",
            "name": "rating_a"
          }
        ]
      }
    JSON

    result = PortableExpressions.from_json(json)

    assert_kind_of(PortableExpressions::Expression, result)
    assert_equal(:-, result.operator)
    result.operands.each do |operand|
      assert_kind_of(PortableExpressions::Variable, operand)
    end
  end

  def test_unknown_object
    json = <<~JSON
      {
        "object": "UnknownObject",
        "name": "10",
        "value": 10
      }
    JSON

    assert_raises(PortableExpressions::DeserializationError) do
      PortableExpressions.from_json(json)
    end
  end

  def test_invalid_json
    assert_raises(PortableExpressions::DeserializationError) do
      PortableExpressions.from_json("abcd")
    end
  end
end
