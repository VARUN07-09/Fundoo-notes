class UsersService

  class InvalidEmailError < StandardError; end
  class InvalidPasswordError < StandardError; end
  class InvalidOtpError < StandardError; end

  @@otp = nil
  @@otp_generated_at = nil

  def self.create_user(params)
    user = User.new(params)
    if user.save
      { success: true, user: user }
    else
      { success: false, errors: user.errors }
    end
  end

  def self.authenticate_user(params)
    Rails.logger.info("🔹 Authenticating user: #{params[:email]}")
  
    user = User.find_by(email: params[:email])
  
    if user.nil?
      Rails.logger.error("❌ Invalid Email: #{params[:email]}")
      raise InvalidEmailError, "Invalid email"
    end
  
    unless user.authenticate(params[:password])
      Rails.logger.error("❌ Invalid Password for user: #{params[:email]}")
      raise InvalidPasswordError, "Invalid password"
    end
  
    token = JsonWebToken.encode(user_id: user.id, name: user.name, email: user.email)
    Rails.logger.info("✅ Login Successful! Token Generated")
  
    { success: true, token: token }
  end

  # def self.forgot_password(email)
  #   begin
  #     user = User.find_by(email: email)
  #     raise InvalidEmailError, "User with this email does not exist" if user.nil?
  
  #     @@otp = generate_otp
  #     @@otp_generated_at = Time.current
  
  #     # Publish OTP message to RabbitMQ
  #     publish_otp_to_queue(user.email, @@otp)
  
  #     { success: true, message: "OTP sent successfully" }
  #   rescue InvalidEmailError => e
  #     { success: false, error: e.message }
  #   rescue StandardError => e
  #     { success: false, error: "Something went wrong: #{e.message}" }
  #   end
  # end
  def self.forgot_password(email)
    begin
      user = User.find_by(email: email)
      raise InvalidEmailError, "User with this email does not exist" if user.nil?
  
      # Generate and save the OTP
      @@otp = generate_otp
      @@otp_generated_at = Time.current
  
      # Publish OTP to RabbitMQ
      publish_otp_to_queue(user.email, @@otp)

      OtpConsumer.start
  
      { success: true, message: "OTP sent successfully" }
    rescue InvalidEmailError => e
      { success: false, error: e.message }
    rescue StandardError => e
      { success: false, error: "Something went wrong: #{e.message}" }
    end
  end

  def self.reset_password(user_id, rp_params)
    raise InvalidOtpError, "OTP has not been generated" if @@otp.nil?

    if rp_params[:otp].to_i == @@otp && (Time.current - @@otp_generated_at < 1.minute)
      user = User.find_by(id: user_id)
      if user
        user.update(password: rp_params[:new_password])
        @@otp = nil  # ✅ Reset OTP after successful password change
        return { success: true }
      else
        return { success: false, errors: "User not found" }
      end
    else
      return { success: false, errors: "Invalid OTP" }
    end
  rescue InvalidOtpError => e
    { success: false, error: e.message }
  end

  # def self.publish_otp_to_queue(email, otp)
  #   queue_name = "otp_email_queue"
  #   channel = RabbitMQ.channel
  #   queue = channel.queue(queue_name, durable: true)

  #   message = { email: email, otp: otp }.to_json
  #   queue.publish(message, persistent: true)

  #   Rails.logger.info("✅ OTP message published to RabbitMQ: #{message}")
  # end
  def self.publish_otp_to_queue(email, otp)
    queue_name = "otp_email_queue"
    
    begin
      # Ensure the channel is open before publishing
      RabbitMQ.ensure_channel_open
      channel = RabbitMQ.channel
      queue = channel.queue(queue_name, durable: true)
  
      message = { email: email, otp: otp }.to_json
      queue.publish(message, persistent: true)
  
      Rails.logger.info("✅ OTP message published to RabbitMQ: #{message}")
    rescue Bunny::Exception => e
      Rails.logger.error("❌ Error publishing OTP message: #{e.message}")
      raise StandardError, "Error publishing OTP message to RabbitMQ: #{e.message}"
    end
  end

  private

  def self.generate_otp
    rand(100000..999999) # Generates a 6-digit OTP
  end

end
