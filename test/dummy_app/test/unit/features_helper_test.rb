require File.expand_path('../../test_helper', __FILE__)
require 'arturo/features_helper'

class ArturoFeaturesHelperTest < ActiveSupport::TestCase

  include ActionView::Helpers::TagHelper
  include ActionDispatch::Assertions::SelectorAssertions
  include Arturo::FeaturesHelper

  attr_accessor :output_buffer

  def bad_feature
    @bad_feature ||= create(:feature).tap do |f|
      f.deployment_percentage = 101
      f.valid?
    end
  end

  def assert_select_in(html, selector, equality=nil, message=nil, &block)
    assert_select(HTML::Document.new(html).root, selector, equality, &block)
  rescue ArgumentError => e
    if e.message =~ /assertion message must be String or Proc/
      raise Test::Unit::AssertionFailedError.new("Expected #{selector.inspect} to match, but it didn't")
    else
      raise
    end
  end

  def test_error_messages_for
    expected = "<ul class=\"errors\"><li class=\"error\">must be less than or equal to 100</li></ul>"
    actual = error_messages_for(bad_feature, :deployment_percentage)

    assert_equal expected, actual
    assert actual.html_safe?
  end

  def test_flash_messages
    html = arturo_flash_messages({
      :notice => 'foo',
      :error  => [ 'bar', 'baz' ]
    })
    assert_select_in html, '.alert.alert-arturo .close[data-dismiss="alert"]', :count => 3
    assert_select_in html, '.alert-notice', /^foo/
    assert_select_in html, '.alert-error',  /^bar/
    assert_select_in html, '.alert-error',  /^baz/
  end

end
