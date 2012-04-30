# my_rails_engine.gemspec
Gem::Specification.new do |gem|
  gem.version = '1.4.0'
  gem.name = 'arturo'
  gem.files = Dir["lib/**/*", "app/**/*", "config/**/*"] + %w(README.md HISTORY.md)
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
  gem.add_runtime_dependency      'rails',        '~> 3.0'
  gem.add_development_dependency  'mocha'
  gem.add_development_dependency  'rake'
  gem.add_development_dependency  'redgreen',     '~> 1.2'
  gem.add_development_dependency  'sqlite3'
  gem.add_development_dependency  'factory_girl', '~> 1.3'
  gem.add_development_dependency  'timecop',      '~> 0.3'
end
