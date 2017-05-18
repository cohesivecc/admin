FactoryGirl.define do
  factory :person do
    prefix "Mr."
    name Faker::Name.name
    email Faker::Internet.safe_email
    bio Faker::Lorem.paragraph
    active true
  end
end
