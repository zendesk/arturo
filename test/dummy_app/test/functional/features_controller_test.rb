require File.expand_path('../../test_helper', __FILE__)
require 'arturo/features_controller'

module ArturoFeaturesControllerTests
  class NonAdminTest < ActionController::TestCase
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
      post :create, :feature => { :name => 'anything' }
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
      put :update, :id => 1, :feature => { :name => 'anything' }
      assert_response :forbidden
    end

    def test_delete_destroy_is_forbidden
      delete :destroy, :id => 1
      assert_response :forbidden
    end

  end

  class AdminTest < ActionController::TestCase
    self.controller_class = Arturo::FeaturesController

    def setup
      Arturo.permit_management do
        true
      end
      @features = [
        Factory(:feature),
        Factory(:feature),
        Factory(:feature)
      ]
    end

    def test_get_index
      get :index
      assert_response :success
      assert_select 'table tbody tr input[type=range]'
      assert_select 'table .no_js input[type=submit]'
    end

    def test_get_new
      get :new
      assert_response :success
    end

    def test_post_create
      post :create, :feature => { :name => 'anything' }
      assert Arturo::Feature.find_by_name('anything').present?
      assert_redirected_to features_path
    end

    def test_get_show
      get :show, :id => @features.first.id
      assert_response :success
    end

    def test_get_edit
      get :edit, :id => @features.first.id
      assert_response :success
    end

    def test_put_update
      put :update, :id => @features.first.id, :feature => { :name => 'anything' }
      assert_redirected_to feature_path(@features.first.reload)
    end

    def test_delete_destroy
      delete :destroy, :id => @features.first.id
      assert_redirected_to features_path
    end

  end

end