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
  if gem.respond_to? :specification_version
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    gem.specification_version = 2
    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      # gem.add_runtime_dependency('gem', '>= 0.4')
    else
      # gem.add_dependency('gem', '>= 0.4')
    end
  else
    # gem.add_dependency('gem', '>= 0.4')
  end

  eval(File.read(File.join(File.dirname(__FILE__), 'development_dependencies.rb')))
end
