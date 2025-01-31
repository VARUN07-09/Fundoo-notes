# app/lib/json_web_token.rb
require 'jwt'

class JsonWebToken
  SECRET_KEY = Rails.application.secret_key_base || ENV['SECRET_KEY']

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i # Expiration time of the token
    JWT.encode(payload, SECRET_KEY) # Encode the payload with the secret key
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0] # Decode the token using the secret key
    HashWithIndifferentAccess.new(decoded) # Convert to HashWithIndifferentAccess for ease of use
  rescue JWT::DecodeError => e
    nil
  end
end
