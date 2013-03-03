require File.expand_path('../../test_helper', __FILE__)
require 'arturo/features_controller'

class ArturoFeaturesControllerNonAdminTest < Arturo::IntegrationTest

  def setup
    Arturo::FeaturesController.any_instance.stubs(:current_user).returns(nil)
  end

  def test_get_index_is_forbidden
    get "/arturo/features"
    assert_response :forbidden
  end

  def test_get_new_is_forbidden
    get "/arturo/features/new"
    assert_response :forbidden
  end

  def test_post_create_is_forbidden
    post "/arturo/features", :feature => { :deployment_percentage => '38' }
    assert_response :forbidden
  end

  def test_get_show_is_forbidden
    get "/arturo/features/1"
    assert_response :forbidden
  end

  def test_get_edit_is_forbidden
    get "/arturo/features/1"
    assert_response :forbidden
  end

  def test_put_update_is_forbidden
    put "/arturo/features/1", :feature => { :deployment_percentae => '81' }
    assert_response :forbidden
  end

  def test_delete_destroy_is_forbidden
    delete "/arturo/features/1"
    assert_response :forbidden
  end

end
