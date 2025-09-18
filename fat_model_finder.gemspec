# frozen_string_literal: true

require_relative "lib/fat_model_finder/version"

Gem::Specification.new do |spec|
  spec.name = "fat_model_finder"
  spec.version = FatModelFinder::VERSION
  spec.authors = ["Max Normand"]
  spec.email = ["maxnormand97@gmail.com"]

  spec.summary = "Working on a new app? Want to find Fat Models, use ME"
  spec.description = "A CLI tool that scans the /app/models dir in a Rails application which will then scan each model
    file to determine weather it is fat or not based on conditions determined in this Gem."
  spec.homepage = "https://github.com/maxnormand97"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/maxnormand97/fat_model_finder"
  # spec.metadata["changelog_uri"] = ""

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # Runtime dependencies
  spec.add_dependency "thor"
  spec.add_dependency "colorize"

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "pry"
end
