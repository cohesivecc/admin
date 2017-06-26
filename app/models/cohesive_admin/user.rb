module CohesiveAdmin
  class User < ActiveRecord::Base

    has_secure_password

    validates :email,         presence: true,
                              format: { with: /(\A(\s*)\Z)|(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z)/i, message: 'must be valid email format (joe@yahoo.com etc.)' },
                              uniqueness: { message: 'is already regisitered' }
    validates :password,      presence: true
    validates :password,      format: { with: /(?=^.{8,}$)((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z])/, message: 'must be at least 8 characters long, and must contain at least one upper-case, one lower-case, and one number or special character' }, allow_blank: true, unless: Proc.new { Rails.env.development? }

    validates :name, presence: true

    def as_json(options={})
      super(except: [:password_digest])
    end

    def reset_password!(login_url=nil)
      new_pass = self.class.random_password
      self.update_attributes(password: new_pass, password_confirmation: new_pass)
      LoginNotifier.password_reset(self, new_pass, login_url).deliver
    end

    class << self

			def model_name
				ActiveModel::Name.new(self, nil, "CohesiveAdmin::User")
			end

      def authenticate(email, password)
        u = find_by_email(email)
        if Rails.env.development?
          u
        else
          u.try(:authenticate, password)
        end
      end

      def random_password(length=10)
        password = ''
        chars = (0..9).to_a + ('A'..'Z').to_a + ('a'..'z').to_a
        length.times do
          password += chars[rand(chars.length)].to_s
        end
        password
      end

    end # class methods


  end
end
