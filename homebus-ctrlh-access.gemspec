# frozen_string_literal: true

require_relative "lib/version"

Gem::Specification.new do |spec|
  spec.name = "homebus-ctrlh-access"
  spec.version = AccessHomebusApp::VERSION
  spec.authors = ["John Romkey"]
  spec.email = ["58883+romkey@users.noreply.github.com"]

  spec.summary = "Homebus publisher for CTRLH's access control system"
  spec.description = "Invoked as a Homebus webhook, publishes access control messages"
  spec.homepage = "https://github.com/HomeBusProjects/homebus-ctrlh-access"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.4"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/HomeBusProjects/homebus-ctrlh-access"
#  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  all_files  = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.files = all_files.grep(%r!^(exe|lib|rubocop)/|^.rubocop.yml$!)
  spec.executables   = all_files.grep(%r!^exe/!) { |f| File.basename(f) }
  spec.bindir        = "exe"
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
