require 'spec_helper'

describe Address do
  let(:address) { build(:address) }
  it "has a valid factory for a location address" do
    address = create(:address)
    expect(address).to be_valid
  end

  it "has a valid factory for a persons address" do
    address = create(:person_address)
    expect(address).to be_valid
  end

  it 'is invalid without a locatable association' do
    address.locatable_type = nil
    address.valid?
    expect(address.errors).to have_key(:locatable_type)
  end

  it 'is invalid with a non-matching locatable tylpe' do
    address.locatable_type = "Manager"
    address.valid?
    expect(address.errors).to have_key(:locatable_type)
  end

  it "it is invalid without a street" do
    address.street = nil
    address.valid?
    expect(address.errors).to have_key(:street)
  end

  it "it is invalid without a city" do
    address.city = nil
    address.valid?
    expect(address.errors).to have_key(:city)
  end

  it "it is invalid without a state" do
    address.state = nil
    address.valid?
    expect(address.errors).to have_key(:state)
  end

end
