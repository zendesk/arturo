# my_rails_engine.gemspec
Gem::Specification.new do |gem|
  gem.version = '0.0.1'
  gem.name = 'arturo'
  gem.files = Dir["lib/**/*", "app/**/*", "config/**/*"] + %w(README.md)
  gem.summary = "Feature sliders, wrapped up in an engine"
  gem.description = "Deploy features incrementally to your users"
  gem.email = "james.a.rosen@gmail.com"
  gem.homepage = "http://jamesarosen.com"
  gem.authors = ["James A. Rosen"]
  gem.test_files = []
  gem.require_paths = [".", "lib"]
  gem.has_rdoc = 'false'
  current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
  gem.specification_version = 2
  gem.add_runtime_dependency('activesupport', '~> 3.0')
  gem.add_runtime_dependency('activerecord', '~> 3.0')

  eval(File.read(File.join(File.dirname(__FILE__), 'development_dependencies.rb')))
end
