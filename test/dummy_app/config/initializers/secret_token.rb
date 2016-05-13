# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
DummyApp::Application.config.secret_token = '2d93f8060fff84c29e7d212af5f6400626f47ebc1e16b2a2bc4d7562cfbe72d149cc8b8ce73b54f9b79c202cd2eb887000e761e3e7eb387a63fe11a4c557d253'

if DummyApp::Application.config.respond_to?(:secret_key_base=)
  DummyApp::Application.config.secret_key_base = '2d93f8060fff84c29e7d212af5f6400626f47ebc1e16b2a2bc4d7562cfbe72d149cc8b8ce73b54f9b79c202cd2eb887000e761e3e7eb387a63fe11a4c557d253'
end
