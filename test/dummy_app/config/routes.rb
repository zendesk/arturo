DummyApp::Application.routes.draw do

  resources :books, :only => 'show' do
    post :holds, :on => :member
  end

end
