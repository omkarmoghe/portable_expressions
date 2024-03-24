class TestElo < Minitest::Test
  def setup
    @env = Expressive::Environment.new(
      "rating_a" => 1000,
      "rating_b" => 1200,
      "scale_factor" => 400,
      "score_a" => 0.5,
      "k_factor" => 32
    )
  end

  def test_elo
    # starting ratings of 2 players
    rating_a = Expressive::Variable.new("rating_a")
    rating_b = Expressive::Variable.new("rating_b")
    scale_factor = Expressive::Variable.new("scale_factor")

    rating_difference = Expressive::Expression.new(:-, rating_b, rating_a)
    exponent = Expressive::Expression.new(:/, rating_difference, scale_factor)
    denominator = Expressive::Expression.new(
      :+,
      Expressive::Scalar.new(1),
      Expressive::Expression.new(:**, Expressive::Scalar.new(10), exponent)
    )
    expected_probability_a = Expressive::Expression.new(:/, Expressive::Scalar.new(1), denominator)

    k_factor = Expressive::Variable.new("k_factor")
    # [0, 1] where 0 is loss, 1 is win, 0.5 is draw
    score_a = Expressive::Variable.new("score_a")
    k_multiplier = Expressive::Expression.new(:-, score_a, expected_probability_a)
    rating_delta = Expressive::Expression.new(:*, k_factor, k_multiplier)
    rating_a_new = Expressive::Expression.new(:+, rating_a, rating_delta)

    assert_equal(1016.0, @env.evaluate(rating_a_new))
  end

  def test_elo_no_local_variables
    rating_a_new = @env.evaluate(
      # starting ratings of 2 players
      Expressive::Expression.new(:-, Expressive::Variable.new("rating_b"), Expressive::Variable.new("rating_a"), output: "rating_difference"),
      Expressive::Expression.new(:/, Expressive::Variable.new("rating_difference"), Expressive::Variable.new("scale_factor"), output: "exponent"),
      Expressive::Expression.new(
        :+,
        Expressive::Scalar.new(1),
        Expressive::Expression.new(:**, Expressive::Scalar.new(10), Expressive::Variable.new("exponent")),
        output: "denominator"
      ),
      Expressive::Expression.new(:/, Expressive::Scalar.new(1), Expressive::Variable.new("denominator"), output: "expected_probability_a"),

      # [0, 1] where 0 is loss, 1 is win, 0.5 is draw
      Expressive::Expression.new(:-, Expressive::Variable.new("score_a"), Expressive::Variable.new("expected_probability_a"), output: "k_multiplier"),
      Expressive::Expression.new(:*, Expressive::Variable.new("k_factor"), Expressive::Variable.new("k_multiplier"), output: "rating_delta"),
      Expressive::Expression.new(:+, Expressive::Variable.new("rating_a"), Expressive::Variable.new("rating_delta"), output: "rating_a_new")
    )

    assert_equal(1016.0, rating_a_new)
  end
end
