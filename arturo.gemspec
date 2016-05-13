require_relative 'lib/arturo/version'

Gem::Specification.new do |s|
  s.name = 'arturo'
  s.version = Arturo::VERSION
  s.authors = ['James A. Rosen']
  s.email = 'james.a.rosen@gmail.com'

  s.summary = 'Feature sliders, wrapped up in an engine'
  s.homepage = 'http://github.com/zendesk/arturo'
  s.files = Dir['lib/**/*', 'app/**/*', 'config/**/*'] + %w(README.md CHANGELOG.md LICENSE)
  s.description = 'Deploy features incrementally to your users'

  s.license = 'APLv2'
  s.required_ruby_version = '>= 2.1'

  s.add_runtime_dependency      'activerecord', '> 3.2', '< 5.1'

  s.add_development_dependency  'rails',        '> 3.2', '< 5.1'
  s.add_development_dependency  'mocha',        '~> 1.1'
  s.add_development_dependency  'minitest',     '> 0', '< 6.0'
  s.add_development_dependency  'minitest-rg',  '> 0', '< 6.0'
  s.add_development_dependency  'rails-dom-testing', '~> 1.0'
  s.add_development_dependency  'sqlite3',      '~> 1.3'
  s.add_development_dependency  'factory_girl', '~> 4.2'
  s.add_development_dependency  'timecop',      '~> 0.3'
  s.add_development_dependency  'wwtd'
end
