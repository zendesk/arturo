# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_dummy_app_session',
  :secret      => '3bcbdbcfc96cfea4a0510518df954ffa1a9bc948e46c6c5f89d76b2ab44fab00853a5e188bf6bb9e05952393fed7605db36f3142bccfc7d5018b6e059fcd7ca5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
