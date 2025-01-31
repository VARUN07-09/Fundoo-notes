Rails.application.configure do
  # Other configurations...

  # Set up the default URL options for the mailer
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Set up the delivery method to be SMTP
  config.action_mailer.delivery_method = :smtp

  config.eager_load = false

  # Configure the SMTP settings
  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com',
  port: 587,
  domain: 'gmail.com',
  user_name: ENV['SMTP_USERNAME'],  # Make sure this is correct
  password: ENV['SMTP_PASSWORD'],   # Ensure this is the correct app password
  authentication: 'plain',
  enable_starttls_auto: true,
  open_timeout: 60,   # Increase timeout if needed
  read_timeout: 60    # Increase timeout if needed
  }

  # Ensure email deliveries are raised in development (useful for debugging)
  config.action_mailer.raise_delivery_errors = true

  # Log email deliveries to the development log
  config.action_mailer.perform_deliveries = true
end
