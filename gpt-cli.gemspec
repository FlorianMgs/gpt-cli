# frozen_string_literal: true

require_relative "lib/gpt-cli/version"

Gem::Specification.new do |spec|
  spec.name = "gpt-cli"
  spec.version = GPTCLI::VERSION
  spec.authors = ["John DeSilva", "Florian Magisson"]
  spec.email = ["desilvjo@umich.edu", "florian@newlogic.com"]

  spec.summary = "A UNIX-ey interface to OpenAI"
  spec.description = "Bring ChatGPT into your CLI as a specialized personal assistant."
  spec.homepage = "https://github.com/FlorianMgs/gpt-cli"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/FlorianMgs/gpt-cli"
  spec.metadata["changelog_uri"] = "https://github.com/FlorianMgs/gpt-cli/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)}) || f.match(%r{gpt-cli-\d+\.\d+\.\d+\.gem})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "quick_openai", "~> 0.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
