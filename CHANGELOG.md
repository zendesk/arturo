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

Set `signing_key` in gemspect only if the file exists.

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
