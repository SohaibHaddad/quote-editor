require "rails_helper"

RSpec.describe Partner, type: :model do
  it "is valid with a name" do
    expect(build(:partner)).to be_valid
  end

  it "requires a name" do
    partner = build(:partner, name: nil)

    expect(partner).not_to be_valid
    expect(partner.errors[:name]).to include("can't be blank")
  end

  it "has many users" do
    association = described_class.reflect_on_association(:users)

    expect(association.macro).to eq(:has_many)
  end

  it "has many quotes" do
    association = described_class.reflect_on_association(:quotes)

    expect(association.macro).to eq(:has_many)
  end
end
