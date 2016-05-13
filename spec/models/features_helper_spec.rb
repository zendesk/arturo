# frozen_string_literal: true
require 'spec_helper'
require 'arturo/features_helper'

describe Arturo::FeaturesHelper do
  include ActionView::Helpers::TagHelper
  include Arturo::FeaturesHelper

  attr_accessor :output_buffer # Used by the features helper

  let(:bad_feature) do
    create(:feature).tap do |f|
      f.deployment_percentage = 101
      f.valid?
    end
  end

  it  'generates an error message for bad features' do
    expected = "<ul class=\"errors\"><li class=\"error\">must be less than or equal to 100</li></ul>"
    actual = error_messages_for_feature(bad_feature, :deployment_percentage)

    expect(actual).to eq(expected)
    expect(actual).to be_html_safe
  end

  it 'sets flash messages' do
    html = arturo_flash_messages(
      :notice => 'foo',
      :error  => [ 'bar', 'baz' ]
    )
    html = Nokogiri::HTML::Document.parse(html)

    expect(html.css('.alert.alert-arturo .close[data-dismiss="alert"]').count).to eq(3)
    expect(html.css('.alert-notice').text).to match(/^foo/)
    expect(html.css('.alert-error')[0].text).to match( /^bar/)
    expect(html.css('.alert-error')[1].text).to match( /^baz/)
  end
end
