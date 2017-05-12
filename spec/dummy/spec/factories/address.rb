FactoryGirl.define do
  factory :address do
    name "John Doe"
    sequence(:email) { |n| "test_#{n}@example.com"}
    password "Hide@ndGoS33ky"
    password_confirmation "Hide@ndGoS33ky"
  end
end
