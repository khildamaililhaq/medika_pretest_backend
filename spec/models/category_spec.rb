require 'rails_helper'

RSpec.describe Category, type: :model do
  it "is valid with valid attributes" do
    category = build(:category)
    expect(category).to be_valid
  end

  it "is invalid without a name" do
    category = build(:category, name: nil)
    expect(category).not_to be_valid
    expect(category.errors[:name]).to include("can't be blank")
  end

  it "is invalid with duplicate name" do
    create(:category, name: "Test Category")
    category = build(:category, name: "Test Category")
    expect(category).not_to be_valid
    expect(category.errors[:name]).to include("has already been taken")
  end

  it "has a default publish value of false" do
    category = Category.new(name: "Test Category")
    expect(category.publish).to eq(false)
  end

  it "can be published" do
    category = build(:category, publish: true)
    expect(category.publish).to eq(true)
  end
end
