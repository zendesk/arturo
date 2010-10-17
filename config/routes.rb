# In Rails edge, the engine can have its own route set
# and be mounted within an application at a sub-URL.
# In 3.0.1, this is not yet available.

# TODO replace this with the commented-out version below
Rails.application.routes.draw do
  resources :features, :controller => 'arturo/features'
  put 'features', :to => 'arturo/features#update_all', :as => 'features'
end

# Arturo::Engine.routes.draw do
#   resources :features, :controller => 'arturo/features'
#   put 'features', :to => 'arturo/features#update_all', :as => 'features'
# end