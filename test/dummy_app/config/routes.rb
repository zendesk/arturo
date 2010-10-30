ActionController::Routing::Routes.draw do |map|
  map.resources :features,  :controller => 'arturo/features'
  map.features '/features', :controller => 'arturo/features', :action => 'update_all', :conditions => { :method => :put }

  map.resources :books, :only => ['show'],
                        :member => { 'holds' => 'post' }
end
