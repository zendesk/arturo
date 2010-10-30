ActionController::Routing::Routes.draw do |map|

  map.resources :books, :only => ['show'],
                        :member => { 'holds' => 'post' }

end
