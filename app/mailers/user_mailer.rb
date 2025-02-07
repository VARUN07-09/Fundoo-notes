# class UserMailer < ApplicationMailer
#     default from: "Varun91thakur@gmail.com"
  
#     def text_mail(email,otp)
#       @message = "Here is your One Time Password: #{otp}"
#       Rails.logger.info "Sending mail to #{email}, Please wait..."
#       mail(to: email, subject: "Reset Password")
#       Rails.logger.info "Sent Successfully!!"
#     end
#   end
class UserMailer < ApplicationMailer
  def text_mail(email, otp)
    @otp = otp
    @user = User.find_by(email: email)  # Ensure you retrieve the user object

    # Send the email
    mail(to: email, subject: 'Your OTP Code')
  end
end
