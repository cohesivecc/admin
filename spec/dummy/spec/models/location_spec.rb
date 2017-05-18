require 'spec_helper'

describe Location do
  let(:location) { build_stubbed(:location) }

  it "has a vaild factory" do
    location = create(:location)
    expect(location).to be_valid
  end

  it "is invalid without a slug" do
    location.slug = nil
    location.valid?
    expect(location.errors).to have_key(:slug)
  end

  it "is invalid with a slug with special characters in it" do
    location.slug = "Speci@l Character"
    location.valid?
    expect(location.errors).to have_key(:slug)
  end
end
