# frozen_string_literal: true
require_relative 'lib/back_ops/version'

Gem::Specification.new do |spec|
  spec.name          = 'back_ops'
  spec.version       = BackOps::VERSION
  spec.authors       = ['Aaron Price']
  spec.email         = ['price.aaron@gmail.com']

  spec.summary       = 'Multi-step background job processor'
  spec.description   = 'BackOps processes multi-step jobs using Sidekiq in a retry-from-failed fashion.'
  spec.homepage      = 'https://github.com/aaronprice/back_ops'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/aaronprice/back_ops'
  spec.metadata['changelog_uri'] = 'https://github.com/aaronprice/back_ops/blob/master/CHANGELOG.md'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'activerecord', '>= 6.1'
  spec.add_dependency 'pg', '>= 1.2'
  spec.add_dependency 'redis', '>= 4.2'
  spec.add_dependency 'sidekiq', '>= 6.1'

  spec.add_development_dependency 'factory_bot', '>= 6.1'
  spec.add_development_dependency 'rspec-rails', '>= 4.0'
end