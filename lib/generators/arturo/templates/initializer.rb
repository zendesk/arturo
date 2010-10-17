require 'arturo'

Arturo.configure do
  permit_management do
    # current_user.present? && current_user.admin?
  end
end
