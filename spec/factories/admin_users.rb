FactoryGirl.define do
  factory :contact, class: CohesiveAdmin::User do
    firstname "John"
    lastname "Doe"
    sequence(:email) { |n| "johndoe#{n}@example.com"}
  end
end
