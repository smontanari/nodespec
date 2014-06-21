require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new
Rake::Task[:build].prerequisites << Rake::Task[:spec]