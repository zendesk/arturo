# frozen_string_literal: true
FactoryBot.define do
  sequence(:feature_symbol) { |n| "feature_#{n}".to_sym }

  factory :feature, :class => Arturo::Feature do
    symbol                { generate(:feature_symbol) }
    deployment_percentage { rand(101) }
  end
end
