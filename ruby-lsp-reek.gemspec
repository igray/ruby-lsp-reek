# frozen_string_literal: true

require_relative "lib/ruby_lsp/reek/version"

Gem::Specification.new do |spec|
  spec.name = "ruby-lsp-reek"
  spec.version = RubyLsp::Reek::VERSION
  spec.authors = ["Iain Gray"]
  spec.email = ["igray@igraycon.com"]

  spec.summary = "Ruby LSP Reek"
  spec.description = "An addon for Ruby LSP that enables linting with reek"
  spec.homepage = "https://github.com/igray/ruby-lsp-reek"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ .git Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("reek", "~> 6.0", ">= 5.0")
  spec.add_dependency("ruby-lsp", "~> 0.17", ">= 0.12.0")
  spec.add_dependency("sorbet-runtime", "~> 0.5", ">= 0.5.5685")

  spec.add_development_dependency "minitest", "~> 5.20"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "rake", "~> 13.1"
  spec.add_development_dependency "rubocop-minitest", "~> 0.35"
  spec.add_development_dependency "rubocop-rake", "~> 0.6"
  spec.add_development_dependency "standard", "~> 1.31"
end
