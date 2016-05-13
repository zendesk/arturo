# frozen_string_literal: true
require File.expand_path('../../test_helper', __FILE__)

class ArturoControllerFiltersTest < ActionController::TestCase
  self.controller_class = BooksController

  def setup
    BooksController::BOOKS.merge!({
      '1' => 'The Varieties of Religious Experience',
      '2' => 'Jane Eyre',
      '3' => 'Robison Crusoe'
    })
    create(:feature, symbol: :books, deployment_percentage: 100)
    create(:feature, symbol: :book_holds, deployment_percentage: 0)
  end

  def test_on_feature_disabled_not_an_action
    refute @controller.action_methods.include?(:on_feature_disabled)
  end

  def test_get_show
    if Rails::VERSION::MAJOR < 5
      get :show, id: '2'
    else
      get :show, params: { id: '2' }
    end
    assert_response :success
  end

  def test_post_holds
    if Rails::VERSION::MAJOR < 5
      post :holds, id: '3'
    else
      post :holds, params: { id: '3' }
    end
    assert_response :forbidden
  end

end
