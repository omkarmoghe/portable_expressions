class TestElo < Minitest::Test
  def setup
    @env = PortableExpressions::Environment.new(
      "rating_a" => 1000,
      "rating_b" => 1200,
      "scale_factor" => 400,
      "score_a" => 0.5,
      "k_factor" => 32
    )
  end

  def test_elo
    # starting ratings of 2 players
    rating_a = PortableExpressions::Variable.new("rating_a")
    rating_b = PortableExpressions::Variable.new("rating_b")
    scale_factor = PortableExpressions::Variable.new("scale_factor")

    rating_difference = PortableExpressions::Expression.new(:-, rating_b, rating_a)
    exponent = PortableExpressions::Expression.new(:/, rating_difference, scale_factor)
    denominator = PortableExpressions::Expression.new(
      :+,
      PortableExpressions::Scalar.new(1),
      PortableExpressions::Expression.new(:**, PortableExpressions::Scalar.new(10), exponent)
    )
    expected_probability_a = PortableExpressions::Expression.new(:/, PortableExpressions::Scalar.new(1), denominator)

    k_factor = PortableExpressions::Variable.new("k_factor")
    # [0, 1] where 0 is loss, 1 is win, 0.5 is draw
    score_a = PortableExpressions::Variable.new("score_a")
    k_multiplier = PortableExpressions::Expression.new(:-, score_a, expected_probability_a)
    rating_delta = PortableExpressions::Expression.new(:*, k_factor, k_multiplier)
    rating_a_new = PortableExpressions::Expression.new(:+, rating_a, rating_delta)

    assert_equal(1016.0, @env.evaluate(rating_a_new))
  end

  def test_elo_no_local_variables
    rating_a_new = @env.evaluate(
      # starting ratings of 2 players
      PortableExpressions::Expression.new(:-, PortableExpressions::Variable.new("rating_b"), PortableExpressions::Variable.new("rating_a"), output: "rating_difference"),
      PortableExpressions::Expression.new(:/, PortableExpressions::Variable.new("rating_difference"), PortableExpressions::Variable.new("scale_factor"), output: "exponent"),
      PortableExpressions::Expression.new(
        :+,
        PortableExpressions::Scalar.new(1),
        PortableExpressions::Expression.new(:**, PortableExpressions::Scalar.new(10), PortableExpressions::Variable.new("exponent")),
        output: "denominator"
      ),
      PortableExpressions::Expression.new(:/, PortableExpressions::Scalar.new(1), PortableExpressions::Variable.new("denominator"), output: "expected_probability_a"),

      # [0, 1] where 0 is loss, 1 is win, 0.5 is draw
      PortableExpressions::Expression.new(:-, PortableExpressions::Variable.new("score_a"), PortableExpressions::Variable.new("expected_probability_a"), output: "k_multiplier"),
      PortableExpressions::Expression.new(:*, PortableExpressions::Variable.new("k_factor"), PortableExpressions::Variable.new("k_multiplier"), output: "rating_delta"),
      PortableExpressions::Expression.new(:+, PortableExpressions::Variable.new("rating_a"), PortableExpressions::Variable.new("rating_delta"), output: "rating_a_new")
    )

    assert_equal(1016.0, rating_a_new)
  end
end
