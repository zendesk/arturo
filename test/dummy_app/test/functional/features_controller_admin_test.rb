# frozen_string_literal: true
require File.expand_path('../../test_helper', __FILE__)
require 'arturo/features_controller'

class ArturoFeaturesControllerAdminTest < Arturo::IntegrationTest
  def setup
    @current_user = Object.new.tap { |u| u.stubs(:admin?).returns(true) }
    Arturo::FeaturesController.any_instance.
      stubs(:current_user).
      returns(@current_user)
    @features = [
      create(:feature),
      create(:feature),
      create(:feature)
    ]
  end

  def test_get_index
    get "/arturo/features"
    assert_response :success
    assert_select 'table tbody tr input[type=range]'
    assert_select "table tfoot a[href='/arturo/features/new']"
    assert_select 'table tfoot input[type=submit]'
  end

  def test_put_update_all
    params = {
      features: {
        @features.first.id => { deployment_percentage: '14' },
        @features.last.id  => { deployment_percentage: '98' }
      }
    }

    if Rails::VERSION::MAJOR < 5
      put "/arturo/features", params
    else
      put "/arturo/features", params: params
    end

    assert_equal '14', @features.first.reload.deployment_percentage.to_s
    assert_equal '98', @features.last.reload.deployment_percentage.to_s
    assert_redirected_to '/arturo/features'
  end

  def test_get_new
    get "/arturo/features/new"
    assert_response :success
  end

  def test_post_create
    if Rails::VERSION::MAJOR < 5
      post "/arturo/features", feature: { symbol: 'anything' }
    else
      post "/arturo/features", params: { feature: { symbol: 'anything' } }
    end
    assert Arturo::Feature.find_by_symbol('anything').present?
    assert_redirected_to '/arturo/features'
  end

  def test_get_show
    get "/arturo/features/#{@features.first.id}"
    assert_response :success
  end

  def test_get_edit
    get "/arturo/features/#{@features.first.id}/edit"
    assert_response :success
  end

  def test_put_update
    if Rails::VERSION::MAJOR < 5
      put "/arturo/features/#{@features.first.id}", feature: { deployment_percentage: '2' }
    else
      put "/arturo/features/#{@features.first.id}", params: { feature: { deployment_percentage: '2' } }
    end
    assert_redirected_to "/arturo/features/#{@features.first.to_param}"
  end

  def test_put_invalid_update
    if Rails::VERSION::MAJOR < 5
      put "/arturo/features/#{@features.first.id}", feature: { deployment_percentage: '-10' }
    else
      put "/arturo/features/#{@features.first.id}", params: { feature: { deployment_percentage: '-10' } }
    end
    assert_response :success
    assert_equal "Could not update #{@features.first.name}: Deployment Percentage must be greater than or equal to 0.", @controller.flash[:alert]
  end

  def test_delete_destroy
    delete "/arturo/features/#{@features.first.id}"
    assert_redirected_to '/arturo/features'
  end

end
