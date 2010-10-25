require File.expand_path('../../test_helper', __FILE__)

class ArturoControllerFiltersTest < ActionController::TestCase
  self.controller_class = BooksController

  def setup
    BooksController::BOOKS.merge!({
      '1' => 'The Varieties of Religious Experience',
      '2' => 'Jane Eyre',
      '3' => 'Robison Crusoe'
    })
    Factory(:feature, :symbol => :books, :deployment_percentage => 100)
    Factory(:feature, :symbol => :book_holds, :deployment_percentage => 0)
  end

  def test_get_show
    get :show, :id => '2'
    assert_response :success
  end

  def test_post_holds
    post :holds, :id => '3'
    assert_response :forbidden
  end

end
