# my_rails_engine.gemspec
Gem::Specification.new do |gem|
  gem.version = '1.9.0'
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

  private_key_path = File.expand_path("~/.ssh/rubgems/arturo-private_key.pem")
  gem.signing_key = private_key_path if File.exists?(private_key_path)
  gem.cert_chain = [ "gem-public_cert.pem" ]

  gem.add_runtime_dependency      'activerecord', '> 3.0', '< 5.0'
  gem.add_development_dependency  'rails'
  gem.add_development_dependency  'mocha'
  gem.add_development_dependency  'rake'
  gem.add_development_dependency  'minitest', '< 5'
  gem.add_development_dependency  'minitest-rg'
  gem.add_development_dependency  'sqlite3'
  gem.add_development_dependency  'factory_girl', '~> 4.2'
  gem.add_development_dependency  'timecop',      '~> 0.3'
  gem.add_development_dependency  'appraisal',    '~> 0.5'
end
