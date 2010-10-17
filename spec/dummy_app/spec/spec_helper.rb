ENV["RAILS_ENV"] = "test"
require 'rubygems'
require 'bundler'
Bundler.setup

require File.expand_path('../dummy_app/config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/spec'
require 'mocha'

require File.expand_path('../prepare_database', __FILE__)
require 'arturo'

class MiniTest::Unit::TestCase

end

MiniTest::Unit.autorun
