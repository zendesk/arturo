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
