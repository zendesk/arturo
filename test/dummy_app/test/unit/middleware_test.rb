# frozen_string_literal: true
require File.expand_path('../../test_helper', __FILE__)

class MiddlewareTest < ActiveSupport::TestCase

  def setup
    @user = User.new(:name => 'Thor', :id => 5791)
  end

  def feature
    @feature ||= create(:feature)
  end

  def underlying_app
    lambda { |env| [ 200, {}, ['Success']] }
  end

  def arturo_app(options = {})
    options[:feature] ||= feature
    Arturo::Middleware.new(underlying_app, options)
  end

  def test_no_recipient_returns_404
    Arturo.enable_feature! feature
    status, headers, body = arturo_app.call({})
    assert_equal 404, status
  end

  def test_middleware_returns_404_if_feature_disabled
    Arturo.disable_feature! feature
    status, headers, body = arturo_app.call({ 'arturo.recipient' => @user })
    assert_equal 404, status
  end

  def test_middleware_passes_through_if_feature_enabled
    Arturo.enable_feature! feature
    status, headers, body = arturo_app.call({ 'arturo.recipient' => @user })
    assert_equal 200, status
    assert_equal ['Success'], body
  end

  def test_custom_on_unavailable
    fail_app = lambda { |env| [ 403, {}, [ 'Forbidden' ] ] }
    Arturo.disable_feature! feature
    status, headers, body = arturo_app(:on_unavailable => fail_app).call({})
    assert_equal 403, status
  end

  def test_feature_recipient
    feature.expects(:enabled_for?).with(@user).returns(false)
    arturo_app.call({ 'arturo.recipient' => @user })
  end

  def test_cusom_feature_recipient_key
    feature.expects(:enabled_for?).with(@user).returns(false)
    arturo_app(:recipient => 'warden.user').call({ 'warden.user' => @user })
  end

end
