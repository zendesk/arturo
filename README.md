## What

Arturo provides feature sliders for Rails. It lets you turn features on and off
just like
[feature flippers](http://code.flickr.com/blog/2009/12/02/flipping-out/),
but offers more fine-grained control. It supports deploying features only for
a given percent* of your users and whitelisting and blacklisting users based
on any criteria you can express in Ruby.

    * The selection isn't random. It's not even pseudo-random. It's completely
      deterministic. This assures that iff a user has a feature one day, unless
      you decrease the deployment percentage of the feature, the user
      will continue to have the feature enabled.

**Note**: the following is the **intended** use of Arturo. It is not yet
complete and neither the 1.0 version of the gem nor the Rails 2.3-specific
branch is available.

## Installation

### In Rails 3, with Bundler

    gem 'arturo', '~> 1.0'

### In Rails 3, without Bundler

    $ gem install arturo --version="~> 1.0"

### In Rails 2, with Bundler

    gem 'arturo', :git => 'git://github.com/jamesarosen/arturo.git',
                  :tag => 'rails_2_3'

### In Rails 2, without Bundler

Put the `rails_2_3` branch of `git://github.com/jamesarosen/arturo.git` into
your `vendor/plugins/` directory. You can use Git submodules or a simple
checkout.

## Configuration

### In Rails

#### Run the migrations:

    $ rails g arturo:migration
    $ rails g arturo:initializer
    $ rails g arturo:route
    $ rails g arturo:assets

#### Edit the configuration

##### Initializer

Open up the newly-generated `config/initializers/arturo_initializer.rb`.
There are configuration options for the following:

 * the block that determines whether a user has permission to manage features
   (see [admin permissions](#adminpermissions))
 * the block that yields the object that has features
   (a User, Person, or Account, see
   [things that have features](#thingsthathavefeatures))
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

`Arturo.permit_management` is a block that is run in the context of
a Controller instance. It should return `true` iff the current user
can manage permissions. Configure the block in
`config/initializers/arturo_initializer.rb`. A reasonable implementation
might be

    Arturo.permit_management do
      current_user.admin?
    end

or

    Arturo.permit_management do
      signed_in? && signed_in_person.can?(:manage_features)
    end

### <span id='thingsthathavefeatures'>Things that Have Features</span>

`Arturo.thing_that_has_features` is a block that is run in the context
of a Controller or View instance. Like `Arturo.permit_management`, it
is configued in `config/initializers/arturo_initializer.rb`.
It should return an `Object` that responds to `#id`. If you want to deploy
features on a per-user basis, a reasonable implementation might be

    Arturo.thing_that_has_features do
      current_user
    end

or

    Arturo.thing_that_has_features do
      signed_in_person
    end

If, on the other hand, you have accounts that have many users and you
want to deploy features on a per-account basis, a reasonable implementation
might be

    Arturo.thing_that_has_features do
      current_account
    end

or

    Arturo.thing_that_has_features do
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
      require_feature! :hold_book
    end

`require_feature!` accepts as a second argument a `Hash` that it passes on
to `before_filter`, so you can use `:only` and `:except` to specify exactly
which actions are filtered.

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

#### Caching

Both the `require_feature!` before filter and the `if_feature_enabled` block
evaluation automatically append a string based on the feature's
`last_modified` timestamp to cache keys that Rails generates. Thus, you don't
have to worry about expiring caches when you increase a feature's deployment
percentage. See `Arturo::CacheSupport` for more information.

## The Name

Arturo gets its name from
[Professor Maximillian Arturo](http://en.wikipedia.org/wiki/Maximillian_Arturo)
on [Sliders](http://en.wikipedia.org/wiki/Sliders).