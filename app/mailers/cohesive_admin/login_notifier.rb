module CohesiveAdmin
  class LoginNotifier < ApplicationMailer
    default from: "noreply@yourwebsite.com"

    layout 'cohesive_admin/mailer'

    def password_reset(user, password, login_url)
      @password   = password
      @login_url  = login_url
      mail(to: user.email, subject: "Cohesive Admin // Password Reset")
    end
  end
end
