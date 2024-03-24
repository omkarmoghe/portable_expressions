class TestParser < Minitest::Test
  def test_variable
    json = <<~JSON
      {
        "object": "Expressive::Variable",
        "name": "score_a",
        "value": 0.5
      }
    JSON

    result = Expressive.from_json(json)

    assert_kind_of(Expressive::Variable, result)
    assert_equal("score_a", result.name)
  end

  def test_scalar
    json = <<~JSON
      {
        "object": "Expressive::Scalar",
        "name": "10",
        "value": 10
      }
    JSON

    assert_kind_of(Expressive::Scalar, Expressive.from_json(json))
  end

  def test_expression
    json = <<~JSON
      {
        "object": "Expressive::Expression",
        "operator": "-",
        "operands": [
          {
            "object": "Expressive::Variable",
            "name": "rating_b",
            "value": 1200
          },
          {
            "object": "Expressive::Variable",
            "name": "rating_a",
            "value": 1000
          }
        ]
      }
    JSON

    result = Expressive.from_json(json)

    assert_kind_of(Expressive::Expression, result)
    assert_equal(:-, result.operator)
    result.operands.each do |operand|
      assert_kind_of(Expressive::Variable, operand)
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

    assert_raises(Expressive::DeserializationError) do
      Expressive.from_json(json)
    end
  end

  def test_invalid_json
    assert_raises(Expressive::DeserializationError) do
      Expressive.from_json("abcd")
    end
  end
end
