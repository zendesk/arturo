# my_rails_engine.gemspec
Gem::Specification.new do |gem|
  gem.version = '2.1.0'
  gem.name = 'arturo'
  gem.files = Dir["lib/**/*", "app/**/*", "config/**/*"] + %w(README.md CHANGELOG.md LICENSE)
  gem.summary = "Feature sliders, wrapped up in an engine"
  gem.description = "Deploy features incrementally to your users"
  gem.license = "APLv2"
  gem.email = "james.a.rosen@gmail.com"
  gem.homepage = "http://github.com/jamesarosen/arturo"
  gem.authors = ["James A. Rosen"]
  gem.test_files = []
  gem.require_paths = [".", "lib"]
  gem.has_rdoc = 'false'
  gem.specification_version = 2
  gem.required_ruby_version = '>= 2.0'

  private_key_path = File.expand_path("~/.ssh/rubgems/arturo-private_key.pem")
  gem.signing_key = private_key_path if File.exists?(private_key_path)
  gem.cert_chain = [ "gem-public_cert.pem" ]

  gem.add_runtime_dependency      'activerecord', '> 3.2', '< 5.1'
  gem.add_development_dependency  'rails',        '> 3.2', '< 5.1'
  gem.add_development_dependency  'mocha',        '~> 1.1'
  gem.add_development_dependency  'rake',         '~> 10.3'
  gem.add_development_dependency  'minitest',     '> 0', '< 6.0'
  gem.add_development_dependency  'minitest-rg',  '> 0', '< 6.0'
  gem.add_development_dependency  'rails-dom-testing', '~> 1.0'
  gem.add_development_dependency  'sqlite3',      '~> 1.3'
  gem.add_development_dependency  'factory_girl', '~> 4.2'
  gem.add_development_dependency  'timecop',      '~> 0.3'
  gem.add_development_dependency  'wwtd',         '~> 0.5'
end
