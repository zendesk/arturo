# frozen_string_literal: true
require 'spec_helper'
require 'arturo/features_controller'

describe Arturo::FeaturesController, type: :request do
  let!(:current_user) { double('Admin', admin?: true) }
  let!(:features) {
    [
      create(:feature),
      create(:feature),
      create(:feature)
    ]
  }

  let(:document_root_element) { Nokogiri::HTML::Document.parse(response.body) }

  before do
    allow_any_instance_of(Arturo::FeaturesController)
      .to receive(:current_user)
      .and_return(current_user)
  end

  it 'responds to a get on index' do
    get '/arturo/features'
    expect(response).to be_successful

    assert_select('table tbody tr input[type=range]')
    assert_select("table tfoot a[href='/arturo/features/new']")
    assert_select('table tfoot input[type=submit]')
  end

  it 'responds to a put on update_all' do
    params = {
      features: {
        features.first.id => { deployment_percentage: '14' },
        features.last.id  => { deployment_percentage: '98' }
      }
    }

    if Rails::VERSION::MAJOR < 5
      put '/arturo/features', params
    else
      put '/arturo/features', params: params
    end

    expect(features.first.reload.deployment_percentage.to_s).to eq('14')
    expect(features.last.reload.deployment_percentage.to_s).to eq('98')
    expect(response).to redirect_to('/arturo/features')
  end

  it 'responds to a get on new' do
    get '/arturo/features/new'
    expect(response).to be_successful
  end

  it 'responds to a post on create' do
    if Rails::VERSION::MAJOR < 5
      post '/arturo/features', feature: { symbol: 'anything' }
    else
      post '/arturo/features', params: { feature: { symbol: 'anything' } }
    end
    expect(Arturo::Feature.find_by_symbol('anything')).to be_present
    expect(response).to redirect_to('/arturo/features')
  end

  def test_get_show
    get "/arturo/features/#{@features.first.id}"
    expect(response).to be_success
  end

  def test_get_edit
    get "/arturo/features/#{@features.first.id}/edit"
    expect(response).to be_success
  end

  def test_put_update
    if Rails::VERSION::MAJOR < 5
      put "/arturo/features/#{@features.first.id}", feature: { deployment_percentage: '2' }
    else
      put "/arturo/features/#{@features.first.id}", params: { feature: { deployment_percentage: '2' } }
    end
    expect(response).to redirect_to("/arturo/features/#{@features.first.to_param}")
  end

  def test_put_invalid_update
    if Rails::VERSION::MAJOR < 5
      put '/arturo/features/#{@features.first.id}', feature: { deployment_percentage: '-10' }
    else
      put '/arturo/features/#{@features.first.id}', params: { feature: { deployment_percentage: '-10' } }
    end

    expect(response).to be_success
    expect(controller.flash[:alert])
      .to eq("Could not update #{@features.first.name}: Deployment Percentage must be greater than or equal to 0.")
  end

  def test_delete_destroy
    delete "/arturo/features/#{@features.first.id}"
    expect(response).to redirect_to('/arturo/features')
  end

end
