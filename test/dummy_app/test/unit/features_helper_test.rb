require File.expand_path('../../test_helper', __FILE__)
require 'arturo/features_helper'

class ArturoFeaturesHelperTest < ActiveSupport::TestCase

  include ActionView::Helpers::TagHelper
  include Arturo::FeaturesHelper

  attr_accessor :output_buffer

  def bad_feature
    @bad_feature ||= Factory(:feature).tap do |f|
      f.deployment_percentage = 101
      f.valid?
    end
  end

  def test_error_messages_for
    expected = "<ul class=\"errors\"><li class=\"error\">must be less than or equal to 100</li></ul>"
    actual = error_messages_for(bad_feature, :deployment_percentage)

    assert_equal expected, actual
    assert actual.html_safe?
  end
end
