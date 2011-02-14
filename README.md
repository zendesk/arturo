## Rails 2.3

This is the Rails 2.3 branch of Arturo. It is available as a gem with the
version number `0.2.3.x`. See [Installation](#installation), below. For
Rails 3.0 support, see the
[master branch](http://github.com/jamesarosen/arturo).

## What

Arturo provides feature sliders for Rails. It lets you turn features on and off
just like
[feature flippers](http://code.flickr.com/blog/2009/12/02/flipping-out/),
but offers more fine-grained control. It supports deploying features only for
a given percent* of your users and whitelisting and blacklisting users based
on any criteria you can express in Ruby.

    * The selection isn't random. It's not even pseudo-random. It's completely
      deterministic. This assures that if a user has a feature on Monday, the
      user will still have it on Tuesday (unless, of course, you *decrease*
      the feature's deployment percentage or change its white- or blacklist
      settings).

### A quick example

Trish, a developer is working on a new feature: a live feed of recent postings
in the user's city that shows up in the user's sidebar. First, she uses Arturo's
view helpers to control who sees the sidebar widget:

    <%# in app/views/layout/_sidebar.html.erb: %>
    <% if_feature_enabled(:live_postings) do %>
    <div class='widget'>
      <h3>Recent Postings</h3>
      <ol id='live_postings'>
      </ol>
    </div>
    <% end %>

Then Trish writes some Javascript that will poll the server for recent
postings and put them in the sidebar widget:

    // in public/javascript/live_postings.js:
    $(function() {
      var livePostingsList = $('#live_postings');
      if (livePostingsList.length > 0) {
        var updatePostingsList = function() {
          livePostingsList.load('/listings/recent');
          setTimeout(updatePostingsList, 30);
        }
        updatePostingsList();
      }
    });

Trish uses Arturo's Controller filters to control who has access to
the feature:

    # in app/controllers/postings_controller:
    class PostingsController < ApplicationController
      require_feature :live_postings, :only => :recent
      # ...
    end

Trish then deploys this code to production. Nobody will see the feature yet,
since it's not on for anyone. (In fact, the feature doesn't yet exist
in the database, which is the same as being deployed to 0% of users.) A week
later, when the company is ready to start deploying the feature to a few
people, the product manager, Vijay, signs in to their site and navigates
to `/features`, adds a new feature called "live_postings" and sets its
deployment percentage to 3%. After a few days, the operations team decides
that the increase in traffic is not going to overwhelm their servers, and
Vijay can bump the deployment percentage up to 50%. A few more days go by
and they clean up the last few bugs they found with the "live_postings"
feature and deploy it to all users.

## <span id='installation'>Installation</span>

Arturo's support for Rails 2.3 is available as a gem with version
numbers matching `0.2.3.x`. The best strategy is to use the
"pessimistic" gem version `"~> 0.2.3"`, which will get you the
latest version of Rails 2.3 support.

### In Rails 2.3, with Bundler

In your `Gemfile`:

    gem 'arturo', :git => 'git://github.com/jamesarosen/arturo.git',
                  :version => '~> 0.2.3'

Unfortunately, Rails 2.3 won't automatically load Arturo as a Plugin
(and thus not pick up its "engine-ness") without **also** declaring
it as a Rails gem. Thus, in `config/environment.rb`:

    config.gem 'arturo', :version => '~> 0.2.3'

### In Rails 2.3, without Bundler

Put the `rails_2_3` branch of `git://github.com/jamesarosen/arturo.git` into
your `vendor/plugins/` directory. You can use Git submodules or a simple
checkout.

## Configuration

### In Rails

#### Run the generators:

    $ script/generate arturo:migration
    $ script/generate arturo:initializer
    $ script/generate arturo:route
    $ script/generate arturo:assets

#### Edit the generated migration as necessary

#### Run the migration:

    $ rake db:migrate

#### Edit the configuration

##### Initializer

Open up the newly-generated `config/initializers/arturo_initializer.rb`.
There are configuration options for the following:

 * the method that determines whether a user has permission to manage features
   (see [admin permissions](#adminpermissions))
 * the method that returns the object that has features
   (e.g. User, Person, or Account; see
   [feature recipients](#featurerecipients))
 * whitelists and blacklists for features
   (see [white- and blacklisting](#wblisting))

##### CSS

Open up the newly-generated `public/stylehseets/arturo_customizations.css`.
You can add any overrides you like to the feature configuration page styles
here. **Do not** edit `public/stylehseets/arturo.css` as that file may be
overwritten in future updates to Arturo.

### In other frameworks

Arturo is a Rails engine. I want to promote reuse on other frameworks by
extracting key pieces into mixins, though this isn't done yet. Open an
[issue](http://github.com/jamesarosen/arturo/issues) and I'll be happy to
work with you on support for your favorite framework.

## Deep-Dive

### <span id='adminpermissions'>Admin Permissions</span>

`Arturo::FeatureManagement#may_manage_features?` is a method that is run in
the context of a Controller or View instance. It should return `true` if
and only if the current user may manage permissions. The default implementation
is as follows:

    current_user.present? && current_user.admin?

You can change the implementation in
`config/initializers/arturo_initializer.rb`. A reasonable implementation
might be

    Arturo.permit_management do
      signed_in? && current_user.can?(:manage_features)
    end

### <span id='featurerecipients'>Feature Recipients</span>

Clients of Arturo may want to deploy new features on a per-user, per-project,
per-account, or other basis. For example, it is likely Twitter deployed
"#newtwitter" on a per-user basis. Conversely, Facebook -- at least in its
early days -- may have deployed features on a per-university basis. It wouldn't
make much sense to deploy a feature to one user of a Basecamp project but not
to others, so 37Signals would probably want a per-project or per-account basis.

`Arturo::FeatureAvailability#feature_recipient` is intended to support these
many use cases. It is a method that returns the current "thing" (a user, account,
project, university, ...) that is a member of the category that is the basis for
deploying new features. It should return an `Object` that responds to `#id`.

The default implementation simply returns `current_user`. Like
`Arturo::FeatureManagement#may_manage_features?`, this method can be configured
in `config/initializers/arturo_initializer.rb`. If you want to deploy features
on a per-account basis, a reasonable implementation might be

    Arturo.feature_recipient do
      current_account
    end

or

    Arturo.feature_recipient do
      current_user.account
    end

If the block returns `nil`, the feature will be disabled.

### <span id='wblisting'>Whitelists & Blacklists</span>

Whitelists and blacklists allow you to control exactly which users or accounts
will have a feature. For example, if all premium users should have the
`:awesome` feature, place the following in
`config/initializers/arturo_initializer.rb`:

    Arturo::Feature.whitelist(:awesome) do |user|
      user.account.premium?
    end

If, on the other hand, no users on the free plan should have the
`:awesome` feature, place the following in
`config/initializers/arturo_initializer.rb`:

    Arturo::Feature.blacklist(:awesome) do |user|
      user.account.free?
    end

### Feature Conditionals

All that configuration is just a waste of time if Arturo didn't modify the
behavior of your application based on feature availability. There are a few
ways to do so.

#### Controller Filters

If an action should only be available to those with a feature enabled,
use a before filter. The following will raise a 403 Forbidden error for
every action within `BookHoldsController` that is invoked by a user who
does not have the `:hold_book` feature.

    class BookHoldsController < ApplicationController
      require_feature :hold_book
    end

`require_feature` accepts as a second argument a `Hash` that it passes on
to `before_filter`, so you can use `:only` and `:except` to specify exactly
which actions are filtered.

If you want to customize the page that is rendered on 403 Forbidden
responses, put the view in
`RAILS_ROOT/app/views/arturo/features/forbidden.html.erb`. Rails will
check there before falling back on Arturo's forbidden page.

#### Conditional Evaluation

Both controllers and views have access to the `if_feature_enabled` and
`feature_enabled?` methods. The former is used like so:

    <% if_feature_enabled?(:reserve_table) %>
      <%= link_to 'Reserve a table', new_restaurant_reservation_path(:restaurant_id => @restaurant) %>
    <% end %>

The latter can be used like so:

    def widgets_for_sidebar
      widgets = []
      widgets << twitter_widget if feature_enabled?(:twitter_integration)
      ...
      widgets
    end

#### Outside a Controller

If you want to check availability outside of a controller or view (really
outside of something that has `Arturo::FeatureAvailability` mixed in), you
can ask either

    Arturo.feature_enabled_for?(:foo, recipient)

or the slightly fancier

    Arturo.foo_enabled_for?(recipient)

Both check whether the `foo` feature exists and is enabled for `recipient`.

#### Caching

**Note**: Arturo does not yet have caching support. Be very careful when
caching actions or pages that involve feature detection as you will get
strange behavior when a user who has access to a feature requests a page
just after one who does not (and vice versa). The following is the
**intended** support for caching.

Both the `require_feature` before filter and the `if_feature_enabled` block
evaluation automatically append a string based on the feature's
`last_modified` timestamp to cache keys that Rails generates. Thus, you don't
have to worry about expiring caches when you increase a feature's deployment
percentage. See `Arturo::CacheSupport` for more information.

## The Name

Arturo gets its name from
[Professor Maximillian Arturo](http://en.wikipedia.org/wiki/Maximillian_Arturo)
on [Sliders](http://en.wikipedia.org/wiki/Sliders).
