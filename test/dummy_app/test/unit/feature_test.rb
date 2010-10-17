require File.expand_path('../../test_helper', __FILE__)

class ArturoFeatureTest < ActiveSupport::TestCase

  def feature
    @feature ||= ::Arturo::Feature.new(:name => 'Foo')
  end

  def bunch_of_things
    @things ||= (1..2000).to_a.map { |i| Object.new.tap { |t| t.stubs(:id).returns(i) } }
  end

  def test_requires_a_name
    feature.name = nil
    assert !feature.valid?
    assert feature.errors[:name].present?
  end

  def test_requires_a_deployment_percentage
    feature.deployment_percentage = nil
    assert !feature.valid?
    assert feature.errors[:deployment_percentage].present?
  end

  def test_sets_deployment_percentage_to_0_by_default
    assert_equal 0, feature.deployment_percentage
  end

  def test_enabled_for_returns_false_for_all_things_when_deployment_percentage_is_0
    feature.deployment_percentage = 0
    bunch_of_things.each { |t| assert !feature.enabled_for?(t) }
  end

  def test_returns_true_for_all_things_when_deployment_percentage_is_100
    feature.deployment_percentage = 100
    bunch_of_things.each { |t| assert feature.enabled_for?(t) }
  end

  def test_returns_true_for_about_deployment_percentage_percent_of_things
    feature.deployment_percentage = 37
    yes = 0
    bunch_of_things.each { |t| yes += 1 if feature.enabled_for?(t) }
    assert_in_delta 0.37 * bunch_of_things.length, yes, 0.02 * bunch_of_things.length
  end
end
