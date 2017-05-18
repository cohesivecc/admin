# CMS user
u = CohesiveAdmin::User.new({ name: "Admin User", email: "info@cohesive.cc", password: 'password', password_confirmation: 'password' })
u.save(validate: false)

@people = []
30.times do |i|
  @people << { prefix: Person::VALID_PREFIXES.sample, name: Faker::Name.unique.name, email: Faker::Internet.safe_email }
end

Person.create(@people)


Job.create([
  { name: 'Plumber' },
  { name: 'Welder' },
  { name: 'Programmer' },
  { name: 'Designer' },
  { name: 'Executive' },
])



Location.create([
  {
      slug: 'cohesive',
      addresses_attributes: [
        {
          street: '100 Eddystone Drive',
          city: 'Hudson',
          state: 'IA',
          zip: '50613'
        }
      ]
  }
])
