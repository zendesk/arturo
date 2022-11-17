# frozen_string_literal: true
module Arturo

  # Adds before filters to controllers for specifying that actions
  # require features to be enabled for the requester.
  #
  # To configure how the controller responds when the feature is
  # *not* enabled, redefine #on_feature_disabled(feature_name).
  # It must render or raise an exception.
  module ControllerFilters

    def self.included(base)
      base.extend Arturo::ControllerFilters::ClassMethods
    end

    def on_feature_disabled(feature_name)
      render :plain => 'Forbidden', :status => 403
    end

    module ClassMethods

      def require_feature(name, options = {})
        method = respond_to?(:before_action) ? :before_action : :before_filter
        send(method, options) do |controller|
          unless controller.feature_enabled?(name)
            controller.on_feature_disabled(name)
          end
        end
      end

    end

  end

end
