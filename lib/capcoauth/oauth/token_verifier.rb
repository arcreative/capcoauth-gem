require 'httparty'

module Capcoauth
  module OAuth
    class TokenVerifier

      class UnauthorizedError < StandardError; end
      class OtherError < StandardError; end

      def self.verify(access_token)
        raise UnauthorizedError if access_token.blank? or access_token.token.blank?
        return access_token if TTLCache.user_id_for(access_token.token)

        # Call Capcoauth
        response = ::HTTParty.get("#{Capcoauth.configuration.capcoauth_url}/oauth/token/info", {
          headers: {
            :'Authorization' => "Bearer #{access_token.token}"
          }
        })

        # Set the user_id from the token response
        if response.code == 200
          access_token.user_id = response.parsed_response['resource_owner_id']
          if response.parsed_response.fetch('application', {}).fetch('uid', nil) === Capcoauth.configuration.client_id
            logger.info("CapcOAuth: The access token for user ##{access_token.user_id} was verified successfully") unless logger.nil?
            TTLCache.update(access_token.token, access_token.user_id)
            access_token
          else
            logger.info("CapcOAuth: The access token for user ##{access_token.user_id} was valid, but for a different OAuth client ID") unless logger.nil?
            raise UnauthorizedError
          end
        elsif response.code == 401
          TTLCache.remove(access_token.token)
          logger.info("CapcOAuth: The access token was invalid, expired, or revoked") unless logger.nil?
          raise UnauthorizedError
        else
          logger.info("CapcOAuth: Received unknown response") unless logger.nil?
          logger.info(JSON.pretty_generate(response)) unless logger.nil?
          raise OtherError
        end
      end

      private

      def self.logger
        Capcoauth.configuration.logger
      end
    end
  end
end
