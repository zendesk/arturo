module Arturo

  # A mixin that is included by Arturo::FeaturesController and is declared
  # as a helper for all views. It provides a single method,
  # may_manage_features?, that returns whether or not the current user
  # may manage features. By default, it is implemented as follows:
  #
  #   def may_manage_features?
  #     current_user.present? && current_user.admin?
  #   end
  #
  # If you would like to change this implementation, it is recommended
  # you do so in config/initializers/arturo_initializer.rb
  module FeatureManagement

    # @return [true,false] whether the current user may manage features
    def may_manage_features?
      current_user.present? && current_user.admin?
    end

  end

end
