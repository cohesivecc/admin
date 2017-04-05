# CMS user
u = CohesiveAdmin::User.new({ name: "Admin User", email: "info@cohesive.cc", password: 'password', password_confirmation: 'password' })
u.save(validate: false)

# Sample people
@first  = ["Tom", "John", "Robert", "Matthew", "Tim", "Kevin", "Mark", "David", "William", "Charles", "Jane", "Sally", "Mary", "Patricia", "Linda", "Elizabeth", "Karen", "Helen", "Laura", "Jessica"]
@last   = ["Johnson", "Smith", "Williams", "Brown", "Miller", "White", "Hansen", "Jones", "Davis", "Taylor", "Moore", "Anderson", "Allen", "Young", "King", "Lee", "Norris", "Martin", "Thomas", "Garcia"]

@people = []
30.times do |i|
  names = [@first.sample, @last.sample]

  @people << { prefix: Person::VALID_PREFIXES.sample, name: names.join(" "), email: "#{names.join(".").downcase}@example.com" }
end

Person.create(@people.uniq)


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
