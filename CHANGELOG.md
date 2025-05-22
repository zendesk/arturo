## Unreleased

Drops support for Ruby 3.0 and 3.1.

Drops support for Rails 6.0 and 6.1.

Adds tests against Ruby 3.4.

Adds tests against Rails 7.2 and 8.0.

## v4.1.1

Fixes missing indifferent_access import

## v4.1.0

Removes upper boundary on ActiveRecord.

Drops support for Ruby < 3.0.

Drops support for Rails < 6.0.

## v4.0.1

Fixes loading issues for apps not using the Rails engine.

## v4.0.0

Stops loading the Rails engine automatically. If you are using the engine, you need to require it explicitly by adding `require 'arturo/engine'` to `application.rb`.

Adds support for Ruby 3.3.

Returns false immediately for `feature_enabled_for?` calls with `nil` recipients.

## v3.0.0

Converts the Feature model into a mixin that should be used by services via a model generator.

Brings back the `warm_cache!` method.

Adds support for Rails 7.1.

## v2.8.0

Drop support for Ruby 2.6

Drop Support for Rails 5.0 & 5.1

Add support for Ruby 3.2

## v2.7.0

Adds ability to register cache update listeners with Arturo::FeatureCaching::AllStrategy that are called when the cache is updated

## v2.6.0

Add support for Rails 7.0

Add support for Ruby 3.0 & 3.1

Drop support for Rails 4.2

Drop support for Ruby 2.4 & 2.5

## v2.5.4

Bug fix: Explicitly require rails engine to avoid errors that ::Rails::Engine cannot be found.

## v2.5.3

Bug fix: Allow using Arturo with ActiveRecord, but without all of Rails.

## v2.5.2

Drop support for Rails 3.2.

Add support for Rails 6.1.

Switch CI from Travis to GitHub Actions.

## v2.2.0

Bug fix: making a feature-update request that fails strict params checks now returns a sensible error instead of throwing an exception

Improvement: better failed-to-update error messages

Support Matrix changes: add Rails 5.0, drop Rails 3.2, add Ruby 2.1.7, add Ruby 2.2.3, drop Ruby 1.9.3

## v2.1.0

Bug fix: `Arturo::SpecialHandling` always compares symbols as strings

Improvmement: Rails 4.2 compatibility

Improvement: relax minitest version constraints

Improvement: add `set_feature!` method to complement `enable_feature!`and `disable_feature!`

## v2.0.0

Bug fix: add missing require to initializer.

Improvement: Remove support for `[feature]_enabled_for?` methods.

Improvement: Use more specific gem versions for development dependencies.

## v1.11.0

Depreaction: `[feature]_enabled_for?` methods

Bug fix: `Arturo.respond_to?` takes an optional second argument, per
`Object.respond_to?`'s signature.

Improvement: support Rails 4.1.

Improvement: use Travis's multiple builds instead of Appraisal.

## v1.10.0

Improvement: Arturo no longer declares a hard runtime dependency on Rails, but
instead only on ActiveRecord. This makes it possible to use `Arturo::Feature`
in non-Rails settings. Feature *management* is still expressed as a Rails engine
and requires `actionpack` and other parts of Rails.

## v1.9.0

Improvement: `Arturo::Feature` is defined in `lib/arturo/feature.rb` instead of
`app/models/arturo/feature.rb`, which means consuming applications can load it
without loading the whole engine.

Improvement: `Arturo::Engine` no longer eagerly loads all engine files; instead,
it uses Rails's `autoload_paths` to ensure classes are loaded as necessary.

Bug fix: the route to `arturo/features_controller#update_all` is now called
`features_update_all`; it had been called simply `features`, which caused
conflict problems in Rails 4.0.

## v1.8.0

Improvement: "All" caching strategy is now smarter about its use of the
`update_at` attribute. It handles the case when a Feature's `updated_at` is
`nil` and queries the database less often to figure out whether any features
have changed.

Bug fix: the engine's `source_root` relied on its `root_path`, which is not
available on all versions of Rails.

## v1.7.0

`Arturo::FeaturesHelper#error_messages_for` has been removed. This only affects
people who have written their own feature-management pages that use this helper.

## v1.6.1

`Arturo::FeaturesHelper#error_messages_for` has been deprecated in favor of
`error_messages_for_feature` because it conflicts with a Rails and DynamicForm
method. It will be removed in v1.7.0. This only affects people who have written
their own feature-management pages that use this helper.

## v1.6.0

Formerly, whitelists and blacklists had to be *feature-specific*:

    Arturo::Feature.whitelist(:foo) do |recipient|
      recipient.plan.has_foo?
    end

Now whitelists and blacklists can be global. The block takes the feature
as the first argument:

    Arturo::Feature.whitelist do |feature, recipient|
      recipient.plan.has?(feature.to_sym)
    end

## v1.5.3

Set `signing_key` in gemspec only if the file exists.

The `FeaturesController` docs erroneously said to override `#permitted?`.
The correct method name is `may_manage_features?`.

## v1.5.2

The gem is now signed. The public key is
[gem-public_cert.pem](./gem-public_cert.pem).

## v1.5.1

Use just ActiveRecord, not all of Rails, when defining different behavior
for different versions.

Unify interface of `Feature` and `NoSuchFeature` so the latter fulfills the
null-object pattern.

## v1.5.0

This project is now licensed under the
[APLv2](https://www.apache.org/licenses/LICENSE-2.0.html).

Arturo now works on Rails 3.0 and Rails 4.0. Helpers are no longer mixed into
the global view, but are under the `arturo_engine` namespace, as is the
convention in Rails 3.1+.

The feature cache will return `NoSuchFeature` for cache misses instead of `nil`,
which clients can treat like a `Feature` that is always off.

Better error messages when managing features, and the addition of the
`arturo_flash_messages` helper method.

Add `Feature.last_updated_at` to get the most recent `updated_at` among all
`Feature`s.

## v1.3.0

Add `Arturo::Middleware`, which passes requests down the stack if an only if
a particular feature is available.

`TestSupport` methods use `Feature.to_feature`.

## v 1.1.0 - cleanup

 * changed `require_feature!` to `require_feature`
 * replaced `Arturo.permit_management` and `Arturo.feature_recipient`
   blocks with instance methods
   `Arturo::FeatureManagement.may_manage_features?` and
   `Arturo::FeatureAvailability.feature_recipient`

## v 1.0.0 - Initial Release

 * `require_feature!` controller filter
 * `if_feature_enabled` controller and view method
 * `feature_enabled?` controller and view method
 * CRUD for features
 * `Arturo.permit_management` to configure management permission
 * `Arturo.feature_recipient` to configure on what basis features are deployed
 * whitelists and blacklists
