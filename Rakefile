require 'rubygems'
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << 'app/controllers' << 'app/mailers' << 'app/models' << 'lib'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'spec/**/*_spec.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Betsy #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('Gemfile')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :test
