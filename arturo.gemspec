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
  s.required_ruby_version = '>= 3.2'

  s.add_runtime_dependency 'activerecord', '>= 7.0'
end
