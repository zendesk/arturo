# frozen_string_literal: true
require 'spec_helper'

describe Arturo::Middleware do
  let(:user)    { User.new(name: 'Thor', id: 5791) }
  let(:feature) { create(:feature) }

  let(:underlying_app) { ->(_env) { [ 200, {}, ['Success']] } }

  def arturo_app(options = {})
    options[:feature] ||= feature
    Arturo::Middleware.new(underlying_app, options)
  end

  it 'returns 404 with no recipient' do
    Arturo.enable_feature! feature
    status, headers, body = arturo_app.call({})
    expect(status).to eq(404)
  end

  it 'retursn 404 if feature is disabled' do
    Arturo.disable_feature! feature
    status, headers, body = arturo_app.call({ 'arturo.recipient' => user })
    expect(status).to eq(404)
  end

  it 'passes through if feature is enabled' do
    Arturo.enable_feature! feature
    status, headers, body = arturo_app.call({ 'arturo.recipient' => user })
    expect(status).to eq(200)
    expect(body).to eq(['Success'])
  end

  it 'uses custom on_unavailable' do
    fail_app = lambda { |env| [ 403, {}, [ 'Forbidden' ] ] }
    Arturo.disable_feature! feature
    status, headers, body = arturo_app(on_unavailable: fail_app).call({})
    expect(status).to eq(403)
  end

  it 'works with feature recipient' do
    expect(feature).to receive(:enabled_for?).with(user).and_return(false)
    arturo_app.call({ 'arturo.recipient' => user })
  end

  it 'works with custom feature recipient key' do
    expect(feature).to receive(:enabled_for?).with(user).and_return(false)
    arturo_app(recipient: 'warden.user').call({ 'warden.user' => user })
  end

end
