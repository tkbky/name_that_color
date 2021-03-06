# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'name_that_color/version'

Gem::Specification.new do |spec|
  spec.name          = 'name_that_color'
  spec.version       = NameThatColor::VERSION
  spec.authors       = ['KY']
  spec.email         = ['infcurious@gmail.com']

  spec.summary       = 'Give color a name'
  spec.description   = 'Give color a proper name and consolidate similar colors into one to DRY up the color scheme.'
  spec.homepage      = 'https://github.com/tkbky/name_that_color.git'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   << 'ntc'
  spec.require_paths = ['lib']

  spec.add_dependency 'thor', '0.20.0'
  spec.add_dependency 'color_diff', '0.1'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'byebug', '~> 9.1'
  spec.add_development_dependency 'rubocop', '0.49.1'
end
