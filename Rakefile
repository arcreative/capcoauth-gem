require 'bundler/setup'
require 'rspec/core/rake_task'

desc 'Default: run specs.'
task :default => :spec

desc 'Run all specs'
RSpec::Core::RakeTask.new(:spec) do |config|
  config.verbose = false
end

namespace :capcoauth do
  # desc 'Install CapcOAuth in dummy app'
  # task :install do
  #   cd 'spec/dummy'
  #   system 'bundle exec rails g capcoauth:install --force'
  # end
end

Bundler::GemHelper.install_tasks