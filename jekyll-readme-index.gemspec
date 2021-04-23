# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("lib", __dir__)
require "jekyll-readme-index/version"

Gem::Specification.new do |s|
  s.name          = "jekyll-readme-index"
  s.version       = JekyllReadmeIndex::VERSION
  s.authors       = ["Ben Balter"]
  s.email         = ["ben.balter@github.com"]
  s.homepage      = "https://github.com/benbalter/jekyll-readme-index"
  s.summary       = "A Jekyll plugin to render a project's README as the site's index."

  s.files         = `git ls-files app lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ["lib"]
  s.license       = "MIT"

  s.add_runtime_dependency "jekyll", ">= 3.0", "< 5.0"
  s.add_development_dependency "rspec", "~> 3.5"
  s.add_development_dependency "rubocop", "~> 0.40"
  s.add_development_dependency "rubocop-jekyll", "~> 0.11.0"
  s.add_development_dependency "rubocop-performance", "~> 1.5"
  s.add_development_dependency "rubocop-rspec", "~> 1.3"
end
