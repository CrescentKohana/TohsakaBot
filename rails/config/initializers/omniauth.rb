# frozen_string_literal: true

require 'omniauth-discord'

protocol = Rails.configuration.user_config.ssl == 'true' ? 'https://' : 'http://'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :discord,
           Rails.application.credentials.dig(:discord, :client_id),
           Rails.application.credentials.dig(:discord, :secret),
           scope: 'identify',
           callback_url: "#{protocol}#{Rails.configuration.user_config.web_host}/auth/discord/callback"
end

# Force redirection when failed OAuth. https://stackoverflow.com/a/11028187
class SafeFailureEndpoint < OmniAuth::FailureEndpoint
  def call
    redirect_to_failure
  end
end

OmniAuth.config.on_failure = SafeFailureEndpoint
