# encoding: utf-8

# require 'rubygems'
# require 'bundler'
# require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << "test"
  test.test_files = FileList['test/test_*.rb']
  test.verbose = true
end

task :default => :test
