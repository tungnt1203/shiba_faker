# frozen_string_literal: true

# This file demonstrates how to use ShibaFaker in a Rails application

# In your Rails application, you would typically configure ShibaFaker in an initializer
# config/initializers/shiba_faker.rb

# Example configuration for a Rails application
# ----------------------------------------------
#
# ShibaFaker.configure do |config|
#   config.ai_provider = :openai
#   config.api_key = ENV['OPENAI_API_KEY']  # Use Rails credentials or environment variables
#   config.model = Rails.env.production? ? "gpt-4" : "gpt-3.5-turbo"
#   config.default_locale = I18n.default_locale
# end

# Usage in a Rails application
# ----------------------------

# Example: Seed file (db/seeds.rb)
#
# puts "Creating fake users..."
# ShibaFaker::Data.new.fake(User, 50)
#
# puts "Creating fake products..."
# ShibaFaker::Data.new.fake(Product, 100)
#
# puts "Creating fake orders with relationships..."
# ShibaFaker::Data.new.fake_with_relations(Order, 200)
#
# puts "Creating fake reviews with relationships..."
# ShibaFaker::Data.new.fake_with_relations(Review, 300)


# Example: Task for generating development data
# ---------------------------------------------
#
# In lib/tasks/dev_data.rake:
#
# namespace :dev do
#   desc "Generate realistic development data using ShibaFaker"
#   task generate_data: :environment do
#     unless Rails.env.production?
#       # Clear existing data (optional)
#       puts "Clearing existing data..."
#       OrderItem.delete_all
#       Order.delete_all
#       Product.delete_all
#       User.delete_all
#
#       # Generate new data
#       puts "Generating users..."
#       ShibaFaker::Data.new.fake(User, 20)
#
#       puts "Generating products..."
#       ShibaFaker::Data.new.fake(Product, 50)
#
#       puts "Generating orders..."
#       ShibaFaker::Data.new.fake_with_relations(Order, 40)
#
#       puts "Generating order items..."
#       ShibaFaker::Data.new.fake_with_relations(OrderItem, 100)
#
#       puts "Done! Generated:"
#       puts "- #{User.count} users"
#       puts "- #{Product.count} products"
#       puts "- #{Order.count} orders"
#       puts "- #{OrderItem.count} order items"
#     else
#       puts "This task should not be run in production environment!"
#     end
#   end
# end


# Example: Factory usage with FactoryBot
# -------------------------------------
#
# # In spec/factories/users.rb:
# FactoryBot.define do
#   factory :user do
#     # Instead of hardcoding values or using Faker gem,
#     # you can use ShibaFaker for more realistic test data
#
#     # Traditional approach with Faker
#     # name { Faker::Name.name }
#     # email { Faker::Internet.email }
#
#     # Example of a custom factory method using ShibaFaker:
#     after(:build) do |user|
#       # This would need to be adapted to your specific needs
#       # as ShibaFaker is designed for bulk operations
#       ai_fields = { "name" => "string", "email" => "string", "bio" => "text" }
#       client = ShibaFaker::Client.new
#       data = client.fake_data("User", ai_fields, 1).first
#
#       user.name = data["name"]
#       user.email = data["email"]
#       user.bio = data["bio"]
#     end
#   end
# end


# Example: Using in a Rails console for ad-hoc data generation
# -----------------------------------------------------------
#
# # In Rails console (rails c):
#
# # Generate 10 blog posts
# ShibaFaker::Data.new.fake(Post, 10)
#
# # Generate 50 comments with associations to existing posts and users
# ShibaFaker::Data.new.fake_with_relations(Comment, 50)
#
# # Generate data for a specific locale
# I18n.with_locale(:fr) do
#   ShibaFaker.configure do |config|
#     config.default_locale = :fr
#   end
#   ShibaFaker::Data.new.fake(Product, 10)
# end


# Integration with model validation
# --------------------------------
#
# # The AI-generated data should respect your model validations,
# # but you may want to verify this:
#
# class Product < ApplicationRecord
#   validates :name, presence: true, uniqueness: true
#   validates :price, numericality: { greater_than: 0 }
#
#   # You can add a class method to generate valid fake data
#   def self.generate_fake(count = 10)
#     data = ShibaFaker::Data.new
#     result = data.fake(self, count)
#
#     # Verify all records were created successfully
#     if count != self.count
#       Rails.logger.warn "Some fake Product records couldn't be created due to validation errors"
#     end
#
#     result
#   end
# end
