Factory.define :feature, :class => Arturo::Feature do |f|
  f.sequence(:name) { |n| "Feature ##{n}" }
  f.deployment_percentage { |_| rand(101) }
end