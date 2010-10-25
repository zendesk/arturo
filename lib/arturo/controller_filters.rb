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
      render :text => 'Forbidden', :status => 403
    end

    module ClassMethods

      def require_feature(name, options = {})
        before_filter options do |controller|
          unless controller.feature_enabled?(name)
            controller.on_feature_disabled(name)
          end
        end
      end

    end

  end

end
