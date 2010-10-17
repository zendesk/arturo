require 'action_view/helpers/tag_helper'
require 'action_view/helpers/form_tag_helper'

module Arturo
  module FeaturesHelper
    include ActionView::Helpers::TagHelper

    def if_feature_enabled(symbol_or_feature, &block)
      feature = ::Arturo::Feature.to_feature(symbol_or_feature)
      return nil if feature.blank?
      thing = ::Arturo.thing_that_has_features.bind(self).call
      if feature.present? && feature.enabled_for?(thing)
        return block.call
      end
    end

    def range_tag(name, value, options = {})
      tag(:input, { 'type' => 'range', 'name' => name, 'id' => sanitize_to_id(name), 'value' => value }.update(options.stringify_keys))
    end

    def error_messages_for(feature, attribute)
      if feature.errors[attribute].any?
        content_tag(:ul, :class => 'errors') do
          feature.errors[attribute].map { |msg| content_tag(:li, msg, :class => 'error') }.join(''.html_safe)
        end
      else
        ''
      end
    end
  end
end
