require 'rubygems'
require 'bundler'
Bundler.setup

require 'minitest/spec'
require 'mocha'

[
  File.dirname(__FILE__),
  File.join(File.dirname(__FILE__), '..', 'lib'),
  File.join(File.dirname(__FILE__), '..', 'app', 'controllers'),
  File.join(File.dirname(__FILE__), '..', 'app', 'helpers'),
  File.join(File.dirname(__FILE__), '..', 'app', 'models')
].each do |dir|
  $LOAD_PATH.unshift(dir)
end

class MiniTest::Unit::TestCase

end

MiniTest::Unit.autorun
