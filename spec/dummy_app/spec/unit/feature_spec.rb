require File.expand_path('../../spec_helper', __FILE__)

describe Arturo::Feature do
  before do
    @feature = ::Arturo::Feature.new(:name => 'Foo')
  end

  it 'must require a name' do
    @feature.name = nil
    @feature.valid?.must_equal false
    @feature.errors[:name].wont_be_empty
  end

  it 'must require a deployment_percentage' do
    @feature.deployment_percentage = nil
    @feature.valid?.must_equal false
    @feature.errors[:deployment_percentage].wont_be_empty
  end

  it 'must set deployment_percentage to 0 by default' do
    @feature.deployment_percentage.must_equal 0
  end
end

describe 'Arturo::Feature#enabled_for?' do
  before do
    @feature = ::Arturo::Feature.new(:name => 'Foo')
    @things = (1..2000).to_a.map { |i| Object.new.tap { |t| t.stubs(:id).returns(i) } }
  end

  it 'must return false for all things when deployment_percentage = 0' do
    @feature.deployment_percentage = 0
    @things.each { |t| @feature.enabled_for?(t).must_equal(false) }
  end

  it 'must return true for all things when deployment_percentage = 100' do
    @feature.deployment_percentage = 100
    @things.each { |t| @feature.enabled_for?(t).must_equal(true) }
  end

  it 'must return true for about deployment_percentage % of things' do
    @feature.deployment_percentage = 37
    yes = 0
    @things.each { |t| yes += 1 if @feature.enabled_for?(t) }
    yes.must_be_within_delta((0.37 * @things.length), (0.02 * @things.length))
  end
end
