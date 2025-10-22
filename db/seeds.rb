# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create sample categories for development and testing
puts "Creating sample categories..."

# Define category names with variety
category_names = [
  "Electronics", "Clothing", "Books", "Home & Garden", "Sports & Outdoors",
  "Beauty & Personal Care", "Automotive", "Health & Household", "Toys & Games",
  "Pet Supplies", "Office Products", "Industrial & Scientific", "Grocery & Gourmet Food",
  "Arts, Crafts & Sewing", "Musical Instruments", "Baby Products", "Luggage & Travel Gear",
  "Video Games", "Cell Phones & Accessories", "Computers & Accessories",
  "Camera & Photo", "Jewelry", "Watches", "Shoes", "Handbags & Wallets",
  "Fashion Jewelry", "Costumes & Accessories", "Novelty & Gag Toys", "Party Supplies",
  "Gift Cards", "Magazine Subscriptions", "Software", "Digital Music", "Movies & TV",
  "Collectibles & Fine Art", "Entertainment Collectibles", "Coins & Paper Money",
  "Stamps", "Sports Collectibles", "Comic Books", "Trading Cards",
  "Die-Cast & Toy Vehicles", "Model Trains & Railway Sets", "Slot Cars, Race Tracks & Accessories",
  "Building Toys", "Dolls & Accessories", "Stuffed Animals & Plush Toys",
  "Games & Accessories", "Dress Up & Pretend Play", "Learning & Education",
  "Arts & Crafts", "Musical Toy Instruments", "Electronic Toys", "Puzzles",
  "Board Games", "Card Games", "Strategy Games", "Role Playing Games",
  "Miniatures", "Warhammer", "Magic: The Gathering", "Yu-Gi-Oh!",
  "Pokémon", "Baseball Cards", "Basketball Cards", "Football Cards",
  "Soccer Cards", "Hockey Cards", "Golf Cards", "Tennis Cards",
  "Racing Cards", "Wrestling Cards", "Boxing Cards", "MMA Cards",
  "Fishing", "Hunting", "Camping & Hiking", "Cycling", "Running",
  "Fitness & Cross-Training", "Weightlifting", "Yoga", "Pilates",
  "Martial Arts", "Boxing", "MMA", "Self Defense", "Team Sports",
  "Basketball", "Football", "Soccer", "Baseball", "Hockey",
  "Lacrosse", "Volleyball", "Tennis", "Golf", "Bowling",
  "Billiards", "Darts", "Shuffleboard", "Table Tennis", "Badminton",
  "Racquetball", "Squash", "Pickleball", "Frisbee", "Disc Golf",
  "Water Sports", "Swimming", "Diving", "Snorkeling", "Scuba Diving",
  "Kayaking", "Canoeing", "Rafting", "Boating", "Sailing",
  "Surfing", "Windsurfing", "Kitesurfing", "Wakeboarding", "Water Skiing"
]

# Create categories with random publish status
created_count = 0
category_names.each do |name|
  category = Category.find_or_create_by!(name: name) do |cat|
    cat.publish = [ true, false ].sample
    created_count += 1
  end
end

puts "Created #{created_count} categories successfully!"
puts "Total categories in database: #{Category.count}"

# Create sample products for development and testing
puts "Creating sample products..."

# Define sample product names
product_names = [
  "Wireless Bluetooth Headphones", "Smartphone Case", "Running Shoes", "Coffee Maker",
  "Yoga Mat", "LED Desk Lamp", "Stainless Steel Water Bottle", "Notebook Set",
  "Wireless Mouse", "Portable Charger", "Resistance Bands", "Digital Camera",
  "Ceramic Mug Set", "Fitness Tracker", "Board Game Collection", "Essential Oil Diffuser",
  "Backpack", "Sunglasses", "Plant Pot Set", "Bluetooth Speaker"
]

# Create products with random category assignment
created_product_count = 0
product_names.each do |name|
  product = Product.find_or_create_by!(name: name) do |prod|
    prod.category = Category.all.sample
    created_product_count += 1
  end
end

puts "Created #{created_product_count} products successfully!"
puts "Total products in database: #{Product.count}"
