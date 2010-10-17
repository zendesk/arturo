require 'arturo'

Arturo.permit_management do
  # current_user.present? && current_user.admin?
end

Arturo.thing_that_has_features do
  # current_user
end