# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: %i[spec rubocop]

namespace :gem do
  desc "Build the belpost gem"
  task :build do
    system "gem build belpost.gemspec"
  end

  desc "Install the gem locally"
  task install: :build do
    system "gem install belpost-*.gem"
  end

  desc "Clean up gem-related files"
  task :clean do
    system "rm -f *.gem"
  end
end

namespace :version do
  desc "Display current version"
  task :show do
    require_relative "lib/belpost/version"
    puts "Current version: #{Belpost::VERSION}"
  end

  desc "Increment patch version (x.y.Z)"
  task :patch do
    update_version(:patch)
  end

  desc "Increment minor version (x.Y.z)"
  task :minor do
    update_version(:minor)
  end

  desc "Increment major version (X.y.z)"
  task :major do
    update_version(:major)
  end
end

def update_version(level)
  version_file = "lib/belpost/version.rb"
  content = File.read(version_file)
  major, minor, patch = content.match(/VERSION\s*=\s*["'](\d+)\.(\d+)\.(\d+)["']/)[1, 3].map(&:to_i)

  case level
  when :major
    major += 1
    minor = 0
    patch = 0
  when :minor
    minor += 1
    patch = 0
  when :patch
    patch += 1
  end

  new_version = "#{major}.#{minor}.#{patch}"
  new_content = content.gsub(/VERSION\s*=\s*["']\d+\.\d+\.\d+["']/, "VERSION = \"#{new_version}\"")
  
  File.write(version_file, new_content)
  puts "Version updated to #{new_version}"
  puts "Don't forget to update CHANGELOG.md!"
end
