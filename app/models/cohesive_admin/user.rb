module CohesiveAdmin
  class User < ActiveRecord::Base
    
    cohesive_admin

    has_secure_password

    validates :email,         presence: true,
                              format: { with: /(\A(\s*)\Z)|(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z)/i, message: 'must be valid email format (joe@yahoo.com etc.)' },
                              uniqueness: { message: 'is already regisitered' }
    validates :password,      format: { with: /(?=^.{8,}$)((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z])/, message: 'must be at least 8 characters long, and must contain at least one upper-case, one lower-case, and one number or special character' }, allow_blank: true

    VALID_TYPES = ['Administrator']

    validates :name, presence: true
    validates :user_type, presence: true, inclusion: { in: VALID_TYPES }

    VALID_TYPES.each do |t|
      define_method(%Q{#{t.strip.gsub(/\s/, '-').underscore}?}) do
        self.user_type == t
      end
    end

    def as_json(options={})
      super(except: [:password_digest])
    end

    def reset_password!
      new_pass = self.class.random_password
      self.update_attributes(password: new_pass, password_confirmation: new_pass)
      LoginNotifier.password_reset(self, new_pass).deliver
    end

    class << self

      def authenticate(email, password)
        find_by_email(email).try(:authenticate, password)
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
