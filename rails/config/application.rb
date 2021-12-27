# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TohsakaWeb
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.autoload_paths << Rails.root.join('lib')

    path = File.join(Rails.root, "config", "user_config.yml")
    if File.exist?(path)
      cfg = YAML.load_file(File.join(path))
      config.hosts << cfg['web_host']
      config.data_dir = cfg['data_dir'] || '../data'
      config.owner_id = cfg['owner_id'].to_i
    end
  end
end
