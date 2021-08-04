# frozen_string_literal: true

module Discordrb
  module Cache
    def user(id)
      id = id.resolve_id
      return @users[id] if @users[id]

      LOGGER.out("Resolving user #{id}")
      begin
        response = API::User.resolve(token, id)
      rescue RestClient::ResourceNotFound, NoMethodError
        return nil
      end
      user = User.new(JSON.parse(response), self)
      @users[id] = user
    end
  end
end
