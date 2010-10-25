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
 