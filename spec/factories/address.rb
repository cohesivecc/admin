FactoryGirl.define do
  factory :address do
    street "100 Eddystone Dr"
    city "Hudson"
    state "IA"
    zip "50643"
    description "Cohesive is a brand and digital agency that ignites creative passion with technology. We believe that the experience between people and brands can create lasting relationships for both. We develop these experiences for clients, partners and friends."
    association :locatable, factory: :location
    factory :person_address do
      association :locatable, factory: :person
    end
  end
end
