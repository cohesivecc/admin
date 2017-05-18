require 'spec_helper'

describe Person do
  let(:person) { build(:person) }
  it "has a valid factory" do
    person = create(:person)
    expect(person).to be_valid
  end

  it "is invalid with a non approved prefix" do
    person.prefix = "Dr."
    person.valid?
    expect(person.errors).to have_key(:prefix)
  end

  it "is invalid without a prefix" do
    person.prefix = nil
    person.valid?
    expect(person.errors).to have_key(:prefix)
  end
end
