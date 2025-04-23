# frozen_string_literal: true

require_relative "lib/belpost/version"

Gem::Specification.new do |spec|
  spec.name = "belpost"
  spec.version = Belpost::VERSION
  spec.authors = ["KuberLite"]
  spec.email = ["kuberlite@gmail.com"]

  spec.summary = "Belpost API wrapper"
  spec.description = "Gem for working with the 'Belpost' delivery service via API"
  spec.homepage = "https://github.com/KuberLite/belpost"
  spec.required_ruby_version = ">= 2.6.0"
  spec.license = "MIT"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/KuberLite/belpost/issues",
    "changelog_uri" => "https://github.com/KuberLite/belpost/releases",
    "source_code_uri" => "https://github.com/belpost/evropochta",
    "homepage_uri" => spec.homepage,
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dotenv"
  spec.add_dependency "dry-schema", "~> 1.0"
  spec.add_dependency "dry-validation", "~> 1.0"
end
