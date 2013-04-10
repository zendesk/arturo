Arturo.instance_eval do

  # Enable a feature; create it if necessary.
  # For use in testing. Not auto-required on load. To load,
  #
  #   require 'arturo/test_support'
  #
  # @param [Symbol, String] name the feature name
  def enable_feature!(name)
    if feature = Arturo::Feature.find_feature(name)
      feature.update_attributes(:deployment_percentage => 100)
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
      feature.update_attributes(:deployment_percentage => 0)
    end
  end

end
