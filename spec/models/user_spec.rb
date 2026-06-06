require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with a username, partner, and password" do
    expect(build(:user)).to be_valid
  end

  it "requires a username" do
    user = build(:user, username: nil)

    expect(user).not_to be_valid
    expect(user.errors[:username]).to include("can't be blank")
  end

  it "enforces case-insensitive username uniqueness" do
    create(:user, username: "Demo")
    duplicate = build(:user, username: "demo")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:username]).to include("has already been taken")
  end

  it "belongs to a partner" do
    association = described_class.reflect_on_association(:partner)

    expect(association.macro).to eq(:belongs_to)
  end

  it "has many created quotes" do
    association = described_class.reflect_on_association(:created_quotes)

    expect(association.macro).to eq(:has_many)
    expect(association.options[:class_name]).to eq("Quote")
    expect(association.options[:foreign_key].to_s).to eq("created_by_id")
  end
end
