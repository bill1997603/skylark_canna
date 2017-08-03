require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Skylark < OmniAuth::Strategies::OAuth2
      option :name, :skylark

      option :client_options, {
        site: 'http://beta.skylarkly.com',
        authorize_url: '/oauth/authorize'
      }

      uid { raw_info['id'] }

      info do
        {
          name: raw_info['name'],
          openid: raw_info['openid']
        }
      end

      def client
        options.authorize_params._ns_id = CONFIG['skylark_adapter']['namespace_id']
        super
      end

      def raw_info
        @raw_info ||= access_token.get('/api/v1/user.json').parsed
      end
    end
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :skylark,
    'f61e8d1a7251fb077f075feefdbd67da291bacc2ae5bdd69e6a7ceefe260f6f6',
    '57047dacb2cfe13ec7d0145be14ed1e518cc45c23f468036738916633c4b8d18'
end
