# frozen_string_literal: true

require_relative 'lib/oidc_provider/version'

Gem::Specification.new do |spec|
  spec.name = 'oidc_provider'
  spec.version = OIDCProvider::VERSION
  spec.authors = ['William Carey']
  spec.email = ['willtcarey@gmail.com']

  spec.summary = 'Uses the openid_connect gem to turn a Rails app into an OpenID Connect provider.'
  spec.description = 'A Rails engine for providing OpenID Connect authorization.'
  spec.homepage = 'https://github.com/brandnewbox/oidc_provider'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  # No changelog yet.
  # spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir['{app,config,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'openid_connect', '~> 2.2.0'
  spec.add_dependency 'rails', '> 4.0'
end
