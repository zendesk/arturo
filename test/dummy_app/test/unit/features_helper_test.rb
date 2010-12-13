require File.expand_path('../../test_helper', __FILE__)
require 'arturo/features_helper'

class ArturoFeaturesHelperTest < ActiveSupport::TestCase

  ERBHandler = ActionView::Template::Handlers::ERB

  class Context
    include Arturo::FeaturesHelper
    attr_accessor :_template, :output_buffer

    def initialize
      @output_buffer = "original"
      @_virtual_path = nil
    end

    def bad_feature
      feature = Factory(:feature)  
      feature.deployment_percentage = 101
      feature.valid?
      return feature
    end
  end
  
  def test_error_messages_for
    output = "<ul class=\"errors\"><li class=\"error\">must be less than or equal to 100</li></ul>"

    template_result = ActionView::Template.new(
      "<%= error_messages_for(bad_feature, :deployment_percentage) %>",
      "partial",
      ERBHandler,
      :virtual_path => "partial"
    )

    assert_equal output, template_result.render( Context.new, {} )
    assert template_result.render( Context.new, {} ).html_safe?
  
  end
end
