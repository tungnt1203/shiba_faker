# frozen_string_literal: true

require "shiba_faker"
require "active_record"

# Configure database connection
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

# Configure ShibaFaker
ShibaFaker.configure do |config|
  config.ai_provider = :openai
  config.api_key = ENV["OPENAI_API_KEY"] # Store your API key in an environment variable
  config.model = "gpt-3.5-turbo" # You can also use "gpt-4" for more advanced data generation
end

# Example 1: Basic Models
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
    t.string :email
    t.integer :age
    t.string :occupation
    t.string :country
    t.timestamps
  end
end

class User < ActiveRecord::Base
end

puts "Generating fake users..."
ShibaFaker::Data.new.fake(User, 5)
puts "#{User.count} users created successfully!"

# Display some sample data
puts "\nSample User Data:"
User.limit(3).each do |user|
  puts "  - #{user.name}, #{user.age}, #{user.occupation} from #{user.country}"
end

# Example 2: Models with Relationships
ActiveRecord::Schema.define do
  create_table :products do |t|
    t.string :name
    t.text :description
    t.decimal :price, precision: 10, scale: 2
    t.integer :stock
    t.string :category
    t.timestamps
  end

  create_table :orders do |t|
    t.references :user, foreign_key: true
    t.datetime :order_date
    t.string :status
    t.decimal :total, precision: 10, scale: 2
    t.timestamps
  end

  create_table :order_items do |t|
    t.references :order, foreign_key: true
    t.references :product, foreign_key: true
    t.integer :quantity
    t.decimal :price, precision: 10, scale: 2
    t.timestamps
  end
end

class Product < ActiveRecord::Base
  has_many :order_items
end

class Order < ActiveRecord::Base
  belongs_to :user
  has_many :order_items
  has_many :products, through: :order_items
end

class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
end

# Generate products first
puts "\nGenerating fake products..."
ShibaFaker::Data.new.fake(Product, 10)
puts "#{Product.count} products created successfully!"

# Now generate orders with relationships
puts "\nGenerating fake orders with relationships..."
ShibaFaker::Data.new.fake_with_relations(Order, 8)
puts "#{Order.count} orders created successfully!"

# Now generate order items with relationships
puts "\nGenerating fake order items with relationships..."
ShibaFaker::Data.new.fake_with_relations(OrderItem, 20)
puts "#{OrderItem.count} order items created successfully!"

# Display sample order data
puts "\nSample Order Data:"
Order.includes(:user, order_items: :product).limit(2).each do |order|
  puts "Order ##{order.id} by #{order.user.name}, Total: $#{order.total}, Status: #{order.status}"
  puts "Items:"
  order.order_items.each do |item|
    puts "  - #{item.quantity}x #{item.product.name} @ $#{item.price} each"
  end
  puts ""
end

# Example 3: Custom Field Handling
puts "\nAdvanced Example: Custom data mapping"
puts "This would normally be handled by the AI, but for demonstration purposes:"

# You can also work with the raw data before inserting it
fields = { "name" => "string", "specialty" => "string", "years_experience" => "integer" }
custom_data = [
  { "name" => "Dr. Smith", "specialty" => "Cardiology", "years_experience" => 15 },
  { "name" => "Dr. Jones", "specialty" => "Neurology", "years_experience" => 8 },
  { "name" => "Dr. Brown", "specialty" => "Pediatrics", "years_experience" => 20 }
]

puts "In a real application, this data would come from the AI based on your model's schema."
puts "Custom data example:"
custom_data.each do |doctor|
  puts "  - #{doctor['name']}, #{doctor['specialty']}, #{doctor['years_experience']} years of experience"
end

puts "\nShibaFaker provides a powerful way to generate realistic test data for your Rails applications!"
