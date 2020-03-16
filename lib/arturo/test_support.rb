# frozen_string_literal: true
Arturo.instance_eval do

  # Enable a feature; create it if necessary.
  # For use in testing. Not auto-required on load. To load,
  #
  #   require 'arturo/test_support'
  #
  # @param [Symbol, String] name the feature name
  def enable_feature!(name)
    if feature = Arturo::Feature.find_feature(name)
      feature = feature.class.find(feature.id) if feature.frozen?
      update_method = Rails::VERSION::MAJOR >= 6 ? :update : :update_attributes
      feature.send(update_method, :deployment_percentage => 100)
    else
      Arturo::Feature.create!(:symbol => name, :deployment_percentage => 100)
    end
  end

  # Disable a feature if it exists.
  # For use in testing. Not auto-required on load. To load,
  #
  #   require 'arturo/test_support'
  #
  # @param [Symbol, String] name the feature name
  def disable_feature!(name)
    if feature = Arturo::Feature.find_feature(name)
      feature = feature.class.find(feature.id) if feature.frozen?
      update_method = Rails::VERSION::MAJOR >= 6 ? :update : :update_attributes
      feature.send(update_method, :deployment_percentage => 0)
    end
  end

  # Enable or disable a feature.  If enabling, create it if necessary.
  # For use in testing. Not auto-required on load. To load,
  #
  #   require 'arturo/test_support'
  #
  # @param [Symbol, String] name the feature name
  # @param Boolean enabled should the feature be enabled?
  def set_feature!(name, enabled)
    if enabled
      enable_feature!(name)
    else
      disable_feature!(name)
    end
  end

end
