require 'arturo'

Arturo.permit_management do
  # current_user.present? && current_user.admin?
  true
end

Arturo.feature_recipient do
  # current_user
end

# Whitelists and Blacklists:
#
# # Enable feature one for all admins:
# Arturo::Feature.whitelist('feature one') do |user|
#   user.admin?
# end
#
# # Disable feature two for all small accounts:
# Arturo::Feature.blacklist('feature two') do |user|
#   user.account.small?
# end
