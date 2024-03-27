# PortableExpressions 🍱

A simple and flexible pure Ruby library for building and evaluating expressions. Expressions can be serialized to and built from JSON strings for portability.

## Installation

Install the gem and add to the application's Gemfile by executing:

  `bundle add portable_expressions`

If bundler is not being used to manage dependencies, install the gem by executing:

  `gem install portable_expressions`

## Usage

> [!IMPORTANT]
> When using the gem, all references to the models below must be prefixed with `PortableExpressions::`. This is omitted in the README for simplicity.

### Scalar

A `Scalar` is the simplest object that can be evaluated. It holds a single `value`. When used in an `Expression`, this `value` must respond to the symbol (i.e. support the method) defined by the `Expression#operator`.

```ruby
Scalar.new(1)
Scalar.new("some string")
```

### Variable

A `Variable` represents a named value stored in the `Environment`. Unlike `Scalars`, `Variables` have no value until they are evaluated by an `Environment`. Evaluating a `Variable` that isn't present in the `Environment` will result in a `MissingVariableError`.

```ruby
variable_a = Variable.new("variable_a")
variable_b = Variable.new("variable_b")

environment = Environment.new(
  "variable_a" => 1
)
environment.evaluate(variable_a) #=> 1
environment.evaluate(variable_b) #=> MissingVariableError
```

### Expression

An expression represents 2 or more `operands` that are reduced using a defined `operator`. The `operands` of an `Expression` can be `Scalars`, `Variables`, or other `Expressions`. All `operands` must respond to the symbol (i.e. support the method) defined by the `Expression#operator`. Just like `Variables`, `Expressions` have non value until they're evaluated by an `Environment`.

Evaluating an `Expression` does the following:
1. all `operands` are first evaluated in order
1. all resulting _values_ are reduced using the symbol defined by the `operator`

In this way evaluation is "lazy"; it won't evaluate a `Variable` or `Expression` until the `operand` is about to be used.

An `Expression` can store its result back into the `Environment` by defining an `output`.

```ruby
# addition
addition = Expression.new(:+, Scalar.new(1), Scalar.new(2))

# multiplication
multiplication = Expression.new(:*, Variable.new("variable_a"), Scalar.new(2))

# storing output
storing_output = Expression.new(:+, Scalar.new(1), Scalar.new(2), output: "one_plus_two")

environment = Environment.new(
  "variable_a" => 2
)
environment.evaluate(addition) #=> 3
environment.evaluate(multiplication) #=> 4
environment.evaluate(storing_output) #=> 3

environment.variables
#=> { "variable_a" => 2, "one_plus_two" => 3 }
```

#### Special `operators`

Some operators, like logical `&&` and `||` are not methods in Ruby, so we pass a special string/symbol that PortableExpressions understands.
- `&&` is represented by `:and`
- `||` is represented by `:or`

### Environment

The `Environment` holds state in the form of a `variables` hash and can evaluate `Expressions`, `Scalars`, and `Variables` within a context. The environment handles updates to the state as `Expressions` run.

```ruby
environment = Environment.new(
  "variable_a" => 1,
  "variable_b" => 2,
)

environment.evaluate(Variable.new("variable_a"))
#=> 1
environment.evaluate(Variable.new("variable_c"))
#=> MissingVariableError "Environment missing variable variable_c."

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

When evaluating multiple objects at a time, the value of the **last** object will be returned.

```ruby
environment = Environment.new
environment.evaluate(
  Scalar.new(1),
  Expression.new(:+, Scalar.new(1), Scalar.new(2))
)
#=> 3
```

You can update or modify the `variables` hash directly at any time.

```ruby
environment = Environment.new(
  "variable_a" => 1
)

environment.evaluate(Variable.new("variable_a")) # => 1
environment.variables["variable_a"] = 2
environment.evaluate(Variable.new("variable_a")) # => 2
```

### Serialization (to JSON)

All models including the `Environment` support serialization via:
- `as_json`: builds a serializable `Hash` representation of the object
- `to_json`: builds a JSON `String` representing the object

All models have a **required** `object` key that indicates the type of object.

### Building (from JSON)

To parse a JSON string, use the `PortableExpressions.from_json` method.

```ruby
environment_json = <<~JSON
  {
    "object": "PortableExpressions::Environment",
    "variables": {
      "score_a": 100
    }
  }
JSON
variable_json = <<~JSON
  {
    "object": "PortableExpressions::Variable",
    "name": "score_a"
  }
JSON

environment = PortableExpressions.from_json(environment_json)
variable_score_a = PortableExpressions.from_json(variable_json)
environment.evaluate(variable_score_a) #=> 100
```

### Beyond math

The examples throughout the README show simple arithmetic to illustrate the mechanics of the library. However, `Scalars` and `Variables` can hold any type of value that's JSON serializable, which allows for more complex use cases such as:

#### Logical statements

```ruby
# variable_a > variable_b && variable_c
a_greater_than_b = Expression.new(
  :>,
  Variable.new("variable_a"),
  Variable.new("variable_b"),
)
conditional = Expression.new(
  :and,
  a_greater_than_b,
  Variable.new("variable_c"),
)
Environment.new(
  "variable_a" => 2,
  "variable_b" => 1,
  "variable_c" => "truthy",
).evaluate(conditional)
#=> true
```

> [!TIP]
> Some operators have special symbols, see [special operators](#special-operators) for more details.

#### String manipulation

```ruby
# Define a reusable `Expression` using `Variables`.
repeat_count = Variable.new("repeat")
string_to_repeat = Variable.new("user_input")
repeater = Expression.new(:*, string_to_repeat, repeat_count)

# Get inputs from some HTTP controller (e.g. Rails)

# GET /repeater?repeat=3&user_input=cool
Environment.new(**params).evaluate(repeater) #=> "coolcoolcool"
# GET /repeater?repeat=3&user_input=alright
Environment.new(**params).evaluate(repeater) #=> "alrightalrightalright"
```

#### Authorization policies

First, we define a portable and reusable policies.

```ruby
# This is a composable policy that checks if a user has permissions for a requested resource and action.
user_permissions = Variable.new("user_permissions")
resource = Variable.new("resource")
action = Variable.new("action")
requested_permission = Expression.new(:+, resource, Scalar.new("."), action)
user_has_permission = Expression.new(:include?, user_permissions, requested_permission, output: "user_has_permission")

# Another composable policy that checks if the resource belongs to a user.
resource_owner = Variable.new("resource_owner")
user_id = Variable.new("user_id")
user_owns_resource = Expression.new(:==, resource_owner, user_id, output: "user_owns_resource")
```

We might decide to combine the policies into a single one:

```ruby
user_owns_resource_and_has_permission = Expression.new(:and, user_owns_resource, user_has_permission)

# Write to a JSON file
File.write("user_owns_resource_and_has_permission.json", user_owns_resource_and_has_permission.to_json)
```

Or we might define a policy the relies on the `output` of other policies. This means that the `Environment` must run the dependencies first in order for their `output` to be available in the `Environment#variables`.

```ruby
user_owns_resource_and_has_permission = Expression.new(
  :and,
  Variable.new("user_owns_resource"),
  Variable.new("user_has_permission")
)

# Each of these can be individually run
File.write("user_has_permission.json", user_has_permission.to_json)
File.write("user_owns_resource.json", user_owns_resource.to_json)
# This one relies on the previous 2 being run, or the corresponding variables being set in the `Environment`.
File.write("user_owns_resource_and_has_permission.json", user_owns_resource_and_has_permission.to_json)
```

These examples demonstrate portability via JSON files, but we can just as easily serve the policy directly to anyone who needs it via some HTTP controller:

```ruby
# E.g. Rails via an `ActionController`
render json: user_owns_resource_and_has_permission.as_json, :ok

# Elsewhere, in the requesting service
user_owns_resource_and_has_permission = PortableExpressions.from_json(response.body.to_s)
```

Then, some consumer with access to the user's permissions and context around the requested `resource` and `action` can execute the policy.

```ruby
environment = Environment.new(
  "user_permissions" => user.permissions #=> ["blog.read", "blog.write", "comment.read", "comment.write"]
  "resource" => some_model.resource_name #=> "comment"
  "action" => "read"
  "resource_owner" => some_model.user_id
  "user_id" => user.id
)

# Combined policy
user_owns_resource_and_has_permission = PortableExpressions.from_json(
  File.read("user_owns_resource_and_has_permission.json")
)
environment.evaluate(user_owns_resource_and_has_permission) #=> true

# Individual policies
user_has_permission = PortableExpressions.from_json(File.read("user_has_permission.json"))
user_owns_resource = PortableExpressions.from_json(File.read("user_owns_resource.json"))
user_owns_resource_and_has_permission = PortableExpressions.from_json(
  File.read("user_owns_resource_and_has_permission.json")
)
environment.evaluate(user_has_permission, user_owns_resource, user_owns_resource_and_has_permission) #=> true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/omkarmoghe/portable_expressions.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
