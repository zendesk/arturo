# frozen_string_literal: true
require 'spec_helper'

describe BooksController, type: :controller do
  before do
    BooksController::BOOKS.merge!(
      '1' => 'The Varieties of Religious Experience',
      '2' => 'Jane Eyre',
      '3' => 'Robison Crusoe'
    )
    create(:feature, symbol: :books, deployment_percentage: 100)
    create(:feature, symbol: :book_holds, deployment_percentage: 0)
  end

  it 'does not consider on_feature_disabled as an action' do
    expect(controller.action_methods).to_not include(:on_feature_disabled)
  end

  it 'works with a get on show' do
    get :show, params: { id: '2' }

    expect(response).to be_successful
  end

  it 'works with a post on holds' do
    post :holds, params: { id: '3' }

    expect(response).to have_http_status(:forbidden)
  end

end
