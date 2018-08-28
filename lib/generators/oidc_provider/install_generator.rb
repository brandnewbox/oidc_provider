# frozen_string_literal: true

# require 'rails/generators/base'
# require 'securerandom'

module OidcProvider

    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc "Creates a OIDCProvider initializer."

      def copy_initializer_file
        copy_file "initializer.rb", "config/initializers/oidc_provider.rb"
      end

      def setup_routes
        route "get '/.well-known/:id', to: 'oidc_provider/discovery#show'"
        route "mount OIDCProvider::Engine, at: '/accounts/oauth'"
      end


      # def copy_locale
      #   copy_file "../../../config/locales/en.yml", "config/locales/devise.en.yml"
      # end

      # def show_readme
      #   readme "README" if behavior == :invoke
      # end

      # def rails_4?
      #   Rails::VERSION::MAJOR == 4
      # end
    end
end
