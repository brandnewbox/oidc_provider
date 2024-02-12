$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "oidc_provider/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "oidc_provider"
  s.version     = OIDCProvider::VERSION
  s.authors     = ["William Carey"]
  s.email       = ["willtcarey@gmail.com"]
  s.homepage    = "https://github.com/brandnewbox/oidc_provider"
  s.summary     = "Uses the openid_connect gem to turn a Rails app into an OpenID Connect provider."
  s.description = "A Rails engine for providing OpenID Connect authorization."
  s.license     = "MIT"

  s.files = Dir["{app,config,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.0"
  s.add_dependency "openid_connect", "~> 1.1.3"

  # s.add_development_dependency "sqlite3"
end
