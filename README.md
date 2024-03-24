# Expressive

A simple and flexible Ruby library to build and evaluate mathematical or other expressions.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add expressive

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install expressive

## Usage

### Models

#### Scalar

A `Scalar` is the simplest object that can be evaluated. It holds a single `value`. When used in an `Expression`, this `value` must respond to the symbol (i.e. support the method) defined by the `Expression#operator`.

```ruby
Scalar.new(1)
```

#### Variable

A `Variable` represents a named value stored in the `Environment`. Unlike `Scalars`, `Variables` have no value until they are evaluated by an `Environment`. Evaluating a `Variable` that isn't present in the `Environment` will result in a `MissingVariableError`.

```ruby
Variable.new("variable_a")
```

#### Expression

An expression represents 2 or more `operands` that are reduced using a defined `operator`. The `operands` of an `Expression` can be `Scalars`, `Variables`, or other `Expressions`. All `operands` must `respond_to?` the method defined by the `operator`.

And `Expression` can store its result back into the `Environment` by defining an `output`.

```ruby
# addition
Expression.new(:+, Scalar.new(1), Scalar.new(2))

# multiplication
Expression.new(:*, Variable.new("variable_a"), Scalar.new(2))

# storing output
Expression.new(:+, Scalar.new(1), Scalar.new(2), output: "one_plus_two")
```

#### Environment

The `Environment` holds state in the form of a `variables` hash and can evaluate `Expressions`, `Scalars`, and `Variables` within a context. The environment handles updates to the state as `Expressions` run.

```ruby
environment = Environment.new(
  "variable_a" => 1,
  "variable_b" => 2,
)

environment.evaluate(Variable.new("variable_a"))
#=> 1

environment.evaluate(
  Expression.new(
    :+,
    Variable.new("variable_a"),
    Variable.new("variable_b"),
    output: "variable_c" # defines where to store the result value
  )
)
#=> 3

environment.variables
#=> { "variable_a" => 1, "variable_b" => 2, "variable_c" => 3 }
```

When evaluating multiple objects at a time, the value of the _last_ object will be returned.

```ruby
environment = Environment.new
environment.evaluate(
  Scalar.new(1),
  Expression.new(:+, Scalar.new(1), Scalar.new(2))
)
#=> 3
```

### Serialization (to JSON)

All models support serialization via:
- `as_json`: builds a serializable hash representation of the object
- `to_json`: builds a JSON string representing the object

### Building (from JSON)

<!-- TODO -->

### Beyond math

<!-- TODO -->

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/omkarmoghe/expressive.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
