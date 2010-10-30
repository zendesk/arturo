ActionController::Base.class_eval do
  include Arturo::FeatureAvailability
  helper  Arturo::FeatureAvailability
  include Arturo::ControllerFilters
  helper  Arturo::FeatureManagement
  helper  Arturo::RangeFormSupport::HelperMethods
end

ActionView::Helpers::FormBuilder.instance_eval do
  include Arturo::RangeFormSupport::FormBuilderMethods
end

require 'rails_generator'
generators_path = File.expand_path('../../generators', __FILE__)
Rails::Generator::Base.sources << Rails::Generator::PathSource.new(:arturo, generators_path)
