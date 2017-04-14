FactoryGirl.define do
  factory :admin_user, class: CohesiveAdmin::User do
    name "John Doe"
    sequence(:email) { |n| "test_#{n}@example.com"}
    password "Hide@ndGoS33ky"
    password_confirmation "Hide@ndGoS33ky"
  end
end
