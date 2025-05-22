For bug reports, open an [issue](https://github.com/zendesk/arturo/issues)
on GitHub.

## Getting Started

1. Install dependencies with `bundle install`
2. Run tests with `rake test`

### Releasing a new version
A new version is published to RubyGems.org every time a change to `version.rb` is pushed to the `main` branch.
In short, follow these steps:
1. Update `version.rb`,
2. update version in all `Gemfile.lock` files,
3. merge this change into `main`, and
4. look at [the action](https://github.com/zendesk/arturo/actions/workflows/publish.yml) for output.

To create a pre-release from a non-main branch:
1. change the version in `version.rb` to something like `1.2.0.pre.1` or `2.0.0.beta.2`,
2. push this change to your branch,
3. go to [Actions → “Publish to RubyGems.org” on GitHub](https://github.com/zendesk/arturo/actions/workflows/publish.yml),
4. click the “Run workflow” button,
5. pick your branch from a dropdown.
