# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "capybara-typhoeus"
  s.version = "0.4.2"
  s.authors = ["Joseph HALTER", "Jonathan TRON"]
  s.summary = "Typhoeus driver for Capybara"
  s.description = "Typhoeus driver for Capybara, allowing testing of REST APIs"
  s.email = ["jonathan.tron@metrilio.com", "joseph.halter@metrilio.com"]
  s.extra_rdoc_files  = "README.md"
  s.files = Dir.glob("{lib,spec}/**/*") +
            %w(LICENSE README.md)
  s.homepage = "https://github.com/TalentBox/capybara-typhoeus"
  s.rdoc_options = ["--main", "README.md", "--inline-source", "--line-numbers"]
  s.require_paths = ["lib"]
  s.test_files = Dir.glob("spec/**/*")

  s.add_runtime_dependency "capybara", ["~> 2.8.0"]
  s.add_runtime_dependency "typhoeus", [">= 0.6.7"]

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rack"
  s.add_development_dependency "sinatra"
end
