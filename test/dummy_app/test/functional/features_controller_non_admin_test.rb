require File.expand_path('../../test_helper', __FILE__)
require 'arturo/features_controller'

class ArturoFeaturesControllerNonAdminTest < ActionController::TestCase
  self.controller_class = Arturo::FeaturesController

  def setup
    Arturo.permit_management do
      false
    end
  end

  def test_get_index_is_forbidden
    get :index
    assert_response :forbidden
  end

  def test_get_new_is_forbidden
    get :new
    assert_response :forbidden
  end

  def test_post_create_is_forbidden
    post :create, :feature => { :deployment_percentage => '38' }
    assert_response :forbidden
  end

  def test_get_show_is_forbidden
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_get_edit_is_forbidden
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_put_update_is_forbidden
    put :update, :id => 1, :feature => { :deployment_percentae => '81' }
    assert_response :forbidden
  end

  def test_delete_destroy_is_forbidden
    delete :destroy, :id => 1
    assert_response :forbidden
  end

end
