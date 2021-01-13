require 'bundler/setup'
require 'bundler/gem_tasks'
require 'bump/tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task default: :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Betsy #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('Gemfile')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
