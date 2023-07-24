# frozen_string_literal: true

namespace :oidc_provider do
  desc 'Generate the lib/oidc_provider_key.pem key file'
  task generate_key: :environment do
    key_filepath = OIDCProvider::IdToken.oidc_provider_key_path

    File.exist?(key_filepath) && raise("ERROR: A key file already exists at #{key_filepath}.")

    passphrase_env_var = OIDCProvider::IdToken::PASSPHRASE_ENV_VAR

    pass_phrase = ENV.fetch(passphrase_env_var, '')

    if pass_phrase == ''
      puts "\033[33mWARNING: You haven't defined a passphrase to be used to " \
           'generate the new key which is concidered as insecured. You can ' \
           "do it by setting the #{passphrase_env_var} environment variable " \
           "and re-run this task.\033[0m"

      raise
    end

    key_file_content = OpenSSL::PKey::RSA.new(2048).export(
      OpenSSL::Cipher.new('AES-128-CBC'),
      pass_phrase
    )

    File.write(key_filepath, key_file_content)
    FileUtils.chmod(0_600, key_filepath)

    puts "SUCCESS: A new key file has been created at #{key_filepath}."
  end
end
