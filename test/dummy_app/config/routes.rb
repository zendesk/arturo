DummyApp::Application.routes.draw do
  mount Arturo::Engine => "/arturo"

  resources :books, :only => 'show' do
    post :holds, :on => :member
  end
end
