require File.expand_path('../../test_helper', __FILE__)

class ArturoFeatureTest < ActiveSupport::TestCase

  def setup
    reset_translations!
  end

  def feature
    @feature ||= create(:feature)
  end

  def bunch_of_things
    @things ||= (1..2000).to_a.map { |i| Object.new.tap { |t| t.stubs(:id).returns(i) } }
  end

  def test_to_feature
    assert_equal feature, ::Arturo::Feature.to_feature(feature)
    assert_equal feature, ::Arturo::Feature.to_feature(feature.symbol)
    assert_equal Arturo::NoSuchFeature, ::Arturo::Feature.to_feature(:does_not_exist).class
  end

  def test_find_feature
    assert_equal feature, ::Arturo::Feature.find_feature(feature)
    assert_equal feature, ::Arturo::Feature.find_feature(feature.symbol)
    assert_nil ::Arturo::Feature.find_feature(:does_not_exist)
  end

  def test_feature_enabled_for_existent_feature
    feature.update_attribute(:deployment_percentage, 100)
    recipient = stub('User', :to_s => 'Paula', :id => 12)
    assert ::Arturo.feature_enabled_for?(feature.symbol, recipient), "#{feature} should be enabled for #{recipient}"
  end

  def test_feature_enabled_for_non_existent_feature
    refute ::Arturo.feature_enabled_for?(:does_not_exist, 'Paula')
  end

  def test_x_enabled_for
    @feature = create(:feature, :deployment_percentage => 100, :symbol => :foo)
    recipient = stub('User', :to_s => 'Paula', :id => 12)
    assert ::Arturo.foo_enabled_for?(recipient), "#{feature} should be enabled for #{recipient}"
  end

  def test_requires_a_symbol
    feature.symbol = nil
    refute feature.valid?
    assert feature.errors[:symbol].present?
  end

  def test_last_updated_at
    Timecop.travel(Time.local(2008, 9, 1, 12, 0, 0))
    feature1 = create(:feature)

    updated_at = Time.local(2011, 9, 1, 12, 0, 0)

    Timecop.freeze(updated_at) do
      feature2 = create(:feature)
    end

    assert_equal updated_at, Arturo::Feature.last_updated_at
  end

  def test_last_updated_at_with_no_features
    assert_nil Arturo::Feature.last_updated_at
  end

  # regression
  # @see https://github.com/jamesarosen/arturo/issues/7
  def test_deployment_percentage_is_not_overwritten_on_create
    new_feature = ::Arturo::Feature.create('symbol' => :foo, 'deployment_percentage' => 37)
    assert_equal '37', new_feature.deployment_percentage.to_s
  end

  def test_requires_a_deployment_percentage
    feature.deployment_percentage = nil
    refute feature.valid?
    assert feature.errors[:deployment_percentage].present?
  end

  def test_symbol_is_readonly
    original_symbol = feature.symbol
    feature.symbol = :foo_bar
    feature.save
    assert_equal original_symbol.to_sym, feature.reload.symbol.to_sym
  end

  def test_sane_default_for_name
    feature.symbol = :foo_bar
    assert_equal 'Foo Bar', feature.name
  end

  def test_name_uses_internationalization_when_available
    define_translation("arturo.feature.#{feature.symbol}", 'Happy Feature')
    assert_equal 'Happy Feature', feature.name
  end

  def test_sets_deployment_percentage_to_0_by_default
    assert_equal 0, ::Arturo::Feature.new.deployment_percentage
  end

  def test_enabled_for_returns_false_if_thing_is_nil
    feature.deployment_percentage = 100
    refute feature.enabled_for?(nil)
  end

  def test_enabled_for_returns_false_for_all_things_when_deployment_percentage_is_0
    feature.deployment_percentage = 0
    bunch_of_things.each { |t| refute feature.enabled_for?(t) }
  end

  def test_returns_true_for_all_non_nil_things_when_deployment_percentage_is_100
    feature.deployment_percentage = 100
    bunch_of_things.each { |t| assert feature.enabled_for?(t) }
  end

  def test_returns_true_for_about_deployment_percentage_percent_of_things
    feature.deployment_percentage = 37
    yes = 0
    bunch_of_things.each { |t| yes += 1 if feature.enabled_for?(t) }
    assert_in_delta 0.37 * bunch_of_things.length, yes, 0.02 * bunch_of_things.length
  end

  def test_returns_false_for_things_with_nil_id_and_not_100
    feature.deployment_percentage = 99
    refute feature.enabled_for?(stub(:id => nil))
  end

  def test_returns_false_for_things_with_nil_id_and_100
    feature.deployment_percentage = 100
    assert feature.enabled_for?(stub(:id => nil))
  end

  def test_enabled_for_is_not_identical_across_features
    foo = create(:feature, :symbol => :foo, :deployment_percentage => 55)
    bar = create(:feature, :symbol => :bar, :deployment_percentage => 55)
    has_foo = bunch_of_things.map { |t| foo.enabled_for?(t) }
    has_bar = bunch_of_things.map { |t| bar.enabled_for?(t) }
    assert has_foo != has_bar
  end

  def test_to_s
    assert feature.to_s.include?(feature.name)
  end

  def test_to_param
    assert_match %r{^#{feature.id}-}, feature.to_param
  end
end
