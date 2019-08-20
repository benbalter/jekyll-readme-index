# encoding: utf-8

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
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

  s.add_runtime_dependency "jekyll", ">= 3", "< 5"
  s.add_development_dependency "rspec", "~> 3.5"
  s.add_development_dependency "rubocop", "~> 0.40"
end
