DummyApp::Application.routes.draw do
  unless Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR == 0
    mount Arturo::Engine => "/arturo"
  end

  resources :books, :only => 'show' do
    post :holds, :on => :member
  end
end
