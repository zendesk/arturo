require 'action_view/helpers/tag_helper'
require 'action_view/helpers/form_tag_helper'

module Arturo
  module FeaturesHelper
    include ActionView::Helpers::TagHelper

    def deployment_percentage_range_and_output_tags(name, value, options = {})
      id = sanitize_to_id(name)
      options = {
        'type' => 'range',
        'name' => name,
        'id' => id,
        'value' => value,
        'min' => '0',
        'max' => '100',
        'step' => '1',
        'class' => 'deployment_percentage'
      }.update(options.stringify_keys)
      tag(:input, options) + deployment_percentage_output_tag(id, value)
    end

    def deployment_percentage_output_tag(id, value)
      content_tag(:output, value, { 'for' => id, 'class' => 'deployment_percentage no_js' })
    end

    def error_messages_for(feature, attribute)
      errors = feature.errors.on(attribute)
      if errors && errors.any?
        content_tag(:ul, :class => 'errors') do
          errors.map { |msg| content_tag(:li, msg, :class => 'error') }.join(''.html_safe)
        end
      else
        ''
      end
    end
  end
end
