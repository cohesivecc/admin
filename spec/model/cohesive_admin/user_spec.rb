require 'spec_helper'

describe CohesiveAdmin::User do
  let(:user) { build(:admin_user) }

  it 'is valid with an email, name, and password' do
    user = CohesiveAdmin::User.new(
      name: 'Test User',
      email: 'test@example.com',
      password: 'Hide@ndGoS33ky',
      password_confirmation: 'Hide@ndGoS33ky')
    expect(user).to be_valid
  end

  it 'has a valid factory' do
    user = create(:admin_user)
    expect(user).to be_valid
  end

  it 'is invalid without an email' do
      user.email = nil
      user.valid?
      expect(user.errors).to have_key(:email)
  end

  it 'is invalid without a name' do
    user.name = nil
    user.valid?
    expect(user.errors).to have_key(:name)
  end

  it 'is invalid without a password' do
      user.password = nil
      user.valid?
      expect(user.errors).to have_key(:password)
  end

  it 'is invalid with a duplicate email address' do
    create(:admin_user, email: 'test@example.com')
    user.email = "test@example.com"
    user.valid?
    expect(user.errors).to have_key(:email)
  end

  it 'is invalid without a password_confirmation' do
    # user =  build(:admin_user, password_confirmation: '')
    user.password_confirmation = ''
    user.valid?
    expect(user.errors).to have_key(:password_confirmation)
  end

  it 'is invalid with a password that is 7 characters' do
    user.password = "P@ssw0r"
    user.password_confirmation = "P@ssw0r"
    user.valid?
    expect(user.errors).to have_key(:password)
  end

  it 'is invalid with a password without an uppercase letter' do
    user.password = "p@ssw0rd"
    user.password_confirmation = "p@ssw0rd"
    user.valid?
    expect(user.errors).to have_key(:password)
  end

  it 'is invalid with a password without a number or special character' do
    user.password = "Passwordd"
    user.password_confirmation = "Password"
    user.valid?
    expect(user.errors).to have_key(:password)
  end

  it 'is invalid with a malformed email address missing the @ symbol' do
    user.email = 'email.email.com'
    user.valid?
    expect(user.errors).to have_key(:email)
  end

  it 'is invalid with a malformed email address missing a TLD' do
    user.email = 'email@emailcom'
    user.valid?
    expect(user.errors).to have_key(:email)
  end

  it 'is invalid with a email address missing domain' do
    user.email = 'email@.com'
    user.valid?
    expect(user.errors).to have_key(:email)
  end

end
