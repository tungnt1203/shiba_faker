# ShibaFaker

ShibaFaker is a Ruby gem that generates realistic fake data for your ActiveRecord models using AI. It leverages OpenAI's GPT models to create contextually appropriate data for your database, making it perfect for development, testing, and demonstration purposes.

## Features

- Generate realistic fake data for any ActiveRecord model
- Automatically respect model relationships and foreign key constraints
- Batch processing for efficient data creation
- Configurable AI provider (currently supports OpenAI)
- Simple API for easy integration into existing projects

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shiba_faker'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install shiba_faker
```

## Configuration

Before using ShibaFaker, you need to configure it with your AI provider details:

```ruby
ShibaFaker.configure do |config|
  config.ai_provider = :openai  # Currently only OpenAI is supported
  config.api_key = "your-openai-api-key"
  config.model = "gpt-3.5-turbo"  # Default, can be changed to any OpenAI model
  config.default_locale = :en  # Default language for generated content
end
```

## Usage

### Basic Usage

To generate fake data for a model:

```ruby
# Generate 10 fake User records (default count)
ShibaFaker::Data.new.fake(User)

# Generate 50 fake Product records
ShibaFaker::Data.new.fake(Product, 50)
```

### Respecting Relationships

ShibaFaker can automatically detect and respect foreign key relationships:

```ruby
# This will detect foreign keys and assign valid IDs from related tables
ShibaFaker::Data.new.fake_with_relations(Order, 30)
```

When using `fake_with_relations`, ShibaFaker will:

1. Detect all foreign keys in the model
2. Find valid IDs from the related tables
3. Generate fake data for all non-foreign key fields
4. Assign random valid IDs to the foreign key fields
5. Insert the data into the database

## Examples

### Example 1: Basic User Model

```ruby
class User < ApplicationRecord
  # has fields: name, email, age, country
end

# Generate 20 fake users
ShibaFaker::Data.new.fake(User, 20)
```

This will generate 20 users with realistic names, valid email addresses, appropriate ages, and real country names.

### Example 2: Complex Relationships

```ruby
class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product
  # has fields: quantity, total_price, status
end

# Assuming User and Product tables already have data
ShibaFaker::Data.new.fake_with_relations(Order, 100)
```

This will generate 100 orders with valid user_id and product_id values, along with realistic quantities, prices, and order statuses.

## How It Works

ShibaFaker works by:

1. Analyzing your ActiveRecord model's schema to determine field names and types
2. Generating an appropriate prompt for the AI based on this schema
3. Requesting realistic fake data from the AI provider
4. Processing the response and inserting it into your database

The AI is instructed to generate data that is contextually appropriate for each field type and name, ensuring that the data is as realistic as possible.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tungnt1203/shiba_faker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/tungnt1203/shiba_faker/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the MIT License.

## Code of Conduct

Everyone interacting in the ShibaFaker project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tungnt1203/shiba_faker/blob/main/CODE_OF_CONDUCT.md).