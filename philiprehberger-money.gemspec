# frozen_string_literal: true

require_relative 'lib/philiprehberger/money/version'

Gem::Specification.new do |spec|
  spec.name          = 'philiprehberger-money'
  spec.version       = Philiprehberger::Money::VERSION
  spec.authors       = ['Philip Rehberger']
  spec.email         = ['me@philiprehberger.com']

  spec.summary       = 'Immutable money value object with integer subunit storage and multi-currency formatting'
  spec.description   = 'A lean money library that stores amounts as integer subunits (cents) to avoid ' \
                       'floating-point errors. Supports arithmetic with banker\'s rounding, fair allocation, ' \
                       'multi-currency formatting, and type-safe currency conversion.'
  spec.homepage      = 'https://github.com/philiprehberger/rb-money'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = spec.homepage
  spec.metadata['changelog_uri']         = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']       = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
