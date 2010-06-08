# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_WCP_session',
  :secret => '9af5b3aa795efc6441936ff4f73b7a47836b96a401a2ece72f12fbcf6a58f13e0f10e10b7843b9601d2c70a74ba54d371c21b84db5c4362e0932a7aeaedd35cb'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
