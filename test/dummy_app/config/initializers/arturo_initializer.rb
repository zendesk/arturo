require 'arturo'

# Configure who may manage features here.
# The following is the default implementation.
# Arturo::FeatureManagement.class_eval do
#   def may_manage_features?
#     current_user.present? && current_user.admin?
#   end
# end

# Configure what receives features here.
# The following is the default implementation.
# Arturo::FeatureAvailability.class_eval do
#   def feature_recipient
#     current_user
#   end
# end

# Whitelists and Blacklists:
#
# Enable feature one for all admins:
# Arturo::Feature.whitelist(:feature_one) do |user|
#   user.admin?
# end
#
# Disable feature two for all small accounts:
# Arturo::Feature.blacklist(:feature_two) do |user|
#   user.account.small?
# end
