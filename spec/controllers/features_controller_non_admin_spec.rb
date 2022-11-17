# frozen_string_literal: true
require 'spec_helper'
require 'arturo/features_controller'

describe Arturo::FeaturesController, type: :request do

  before do
    allow_any_instance_of(Arturo::FeaturesController)
      .to receive(:current_user).and_return(nil)
  end

  it 'returns forbidden with get on index' do
    get '/arturo/features'
    expect(response).to have_http_status(:forbidden)
  end

  it 'returns forbidden with get on new' do
    get '/arturo/features/new'
    expect(response).to have_http_status(:forbidden)
  end

  it 'returns forbidden with post on create' do
    post '/arturo/features', params: { feature: { deployment_percentage: '38' } }

    expect(response).to have_http_status(:forbidden)
  end

  it 'returns forbidden with get on show' do
    get '/arturo/features/1'
    expect(response).to have_http_status(:forbidden)
  end

  it 'returns forbidden with get on edit' do
    get '/arturo/features/1'
    expect(response).to have_http_status(:forbidden)
  end

  it 'returns forbidden with put on update' do
    put '/arturo/features/1', params: { feature: { deployment_percentage: '81' } }

    expect(response).to have_http_status(:forbidden)
  end

  it 'returns forbidden with delete on destroy' do
    delete '/arturo/features/1'
    expect(response).to have_http_status(:forbidden)
  end

end
