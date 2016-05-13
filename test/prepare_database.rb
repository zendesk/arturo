# frozen_string_literal: true
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Schema.verbose = false
require_relative 'dummy_app/db/schema.rb'
