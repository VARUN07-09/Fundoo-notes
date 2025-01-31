class User < ApplicationRecord
    has_secure_password
  
    validates :name, presence: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email" }
    validates :password, presence: true, length: { minimum: 8 }, format: {
      with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%?&])[A-Za-z\d@$!%?&]+\z/,
      message: "must include at least one lowercase letter, one uppercase letter, one number, and one special character"
    }
    validates :phone_number, presence: true, uniqueness: true, length: { is: 14 }, format: {
      with: /\A\+91[-\s]?\d{10}\z/, message: "must be an Indian phone number starting with +91"
    }
  end
  