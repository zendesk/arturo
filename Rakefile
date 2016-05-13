require 'bundler/setup'
require 'rake'
require 'wwtd/tasks'

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'app/controllers' << 'app/mailers' << 'app/models' << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

task default: :test

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Betsy #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('Gemfile')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
