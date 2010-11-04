# Gem versions for Rails 2.3 support should be numbered 0.2.3.x.
# Unfortunately, this means the versions will not follow
# the principles of semantic versioning. Ah well, another day
# another battle.
Gem::Specification.new do |gem|
  gem.version = '0.2.3.4'
  gem.name = 'arturo'
  gem.files = Dir["lib/**/*", "app/**/*", "config/**/*", "rails/*"] + %w(README.md HISTORY.md)
  gem.summary = "Feature sliders, wrapped up in an engine"
  gem.description = "Deploy features incrementally to your users"
  gem.email = "james.a.rosen@gmail.com"
  gem.homepage = "http://github.com/jamesarosen/arturo"
  gem.authors = ["James A. Rosen"]
  gem.test_files = []
  gem.require_paths = [".", "lib"]
  gem.has_rdoc = 'false'
  current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
  gem.specification_version = 2
  gem.add_runtime_dependency      'rails',        '~> 2.3.8'
  gem.add_development_dependency  'mocha'
  gem.add_development_dependency  'rake'
  gem.add_development_dependency  'redgreen',     '~> 1.2'
  gem.add_development_dependency  'sqlite3-ruby', '~> 1.3'
  gem.add_development_dependency  'factory_girl', '~> 1.3'
end
