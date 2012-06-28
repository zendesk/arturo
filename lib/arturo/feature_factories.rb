Factory.define :feature, :class => Arturo::Feature do |f|
  f.sequence(:symbol) { |n| "feature_#{n}".to_sym }
  f.deployment_percentage { |_| rand(101) }
end

Factory.define :global_feature, :class => Arturo::GlobalFeature do |f|
  f.sequence(:symbol) { |n| "feature_#{n}".to_sym }
end