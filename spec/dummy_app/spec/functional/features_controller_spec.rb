require File.expand_path('../../spec_helper', __FILE__)

describe Arturo::FeaturesController do
  include ActionController::TestCase::Behavior

  describe 'while signed in as a non-administrator' do
    before do
      puts '1'
      Arturo.permit_management do
        false
      end
    end

    describe 'a GET to :index' do
      before do
        puts '2'
      end

      it 'must be fooish' do
        puts '3'
      end
    end
  end

  

end