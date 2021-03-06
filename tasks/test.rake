require 'parallel'
require_relative "application_generator"

desc "Run the full suite using parallel_tests to run on multiple cores"
task test: [:setup, :spec, :cucumber]

desc "Create a test rails app for the parallel specs to run against"
task :setup, [:rails_env, :template] do |_t, opts|
  ActiveAdmin::ApplicationGenerator.new(opts).generate
end

desc "Run the specs in parallel"
task :spec do
  system("parallel_rspec --serialize-stdout --verbose spec/")
end

namespace :spec do
  %i(unit request).each do |type|
    desc "Run the #{type} specs in parallel"
    task type do
      system("parallel_rspec --serialize-stdout --verbose spec/#{type}")
    end
  end
end

desc "Run the cucumber scenarios in parallel"
task cucumber: [:"cucumber:regular", :"cucumber:reloading"]

namespace :cucumber do
  desc "Run the standard cucumber scenarios in parallel"
  task :regular do
    system("parallel_cucumber --serialize-stdout --verbose features/")
  end

  desc "Run the cucumber scenarios that test reloading"
  task :reloading do
    system("cucumber --profile class-reloading")
  end
end
