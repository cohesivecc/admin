require 'spec_helper'

describe CohesiveAdmin::User do
  it 'is valid with an email, name, and password' do
    user = CohesiveAdmin::User.new(
      name: 'Test User',
      email: 'test@example.com',
      password: 'Hide@ndGoS33ky',
      password_confirmation: 'Hide@ndGoS33ky')
    expect(user).to be_valid
  end

  it 'is invalid without an email' do
      user = CohesiveAdmin::User.new(email: nil)
      user.valid?
      expect(user.errors).to have_key(:email)
  end

  it 'is invalid without a name' do
    user = CohesiveAdmin::User.new(name: nil)
    user.valid?
    expect(user.errors).to have_key(:name)
  end

  it 'is invalid without a password' do
      user = CohesiveAdmin::User.new(password: nil)
      user.valid?
      expect(user.errors).to have_key(:password)
  end

  it 'is invalid with a duplicate email address' do
    CohesiveAdmin::User.create(
      name: 'Test User',
      email: 'test@example.com',
      password: 'Hide@ndGoS33ky',
      password_confirmation: 'Hide@ndGoS33ky')
    user =   CohesiveAdmin::User.new(
        name: 'Bad Tester',
        email: 'test@example.com',
        password: 'Hide@ndGoS33ky',
        password_confirmation: 'Hide@ndGoS33ky')
    user.valid?
    expect(user.errors).to have_key(:email)
  end

end
