# to be evaluated within the context of a Gemspec or a Gemfile

# Bundler can't sync up with .gemspec files for
# development dependencies. Until it can, make sure to keep these
# two blocks parallel.
if Object.const_defined?(:Bundler) && Bundler.const_defined?(:Dsl) && self.kind_of?(Bundler::Dsl)
  group :development do
    gem  'mocha'
    gem  'rake'
    gem  'redgreen',      '~> 1.2'
    gem  'sqlite3-ruby',  '~> 1.3', :require => 'sqlite3'
    gem  'factory_girl',  '~> 1.3'
  end  
else #gemspec  
  gem.add_development_dependency  'mocha'
  gem.add_development_dependency  'rake'
  gem.add_development_dependency  'redgreen',     '~> 1.2'
  gem.add_development_dependency  'sqlite3-ruby', '~> 1.3'
  gem.add_development_dependency  'factory_girl', '~> 1.3'
end
