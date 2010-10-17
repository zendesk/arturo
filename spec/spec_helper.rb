require 'rubygems'
require 'bundler'
Bundler.setup

require 'minitest/spec'
require 'mocha'
require 'rails'
require 'action_controller'
require 'action_dispatch/testing/test_process'

[
  File.dirname(__FILE__),
  File.join(File.dirname(__FILE__), '..', 'lib'),
  File.join(File.dirname(__FILE__), '..', 'app', 'controllers'),
  File.join(File.dirname(__FILE__), '..', 'app', 'helpers'),
  File.join(File.dirname(__FILE__), '..', 'app', 'models')
].each do |dir|
  $LOAD_PATH.unshift(dir)
end

require File.expand_path('../prepare_database', __FILE__)
require File.expand_path('../../config/routes.rb', __FILE__)
require 'arturo'

class MiniTest::Unit::TestCase

end

MiniTest::Unit.autorun
