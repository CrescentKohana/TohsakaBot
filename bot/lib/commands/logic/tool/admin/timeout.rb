# frozen_string_literal: true

module TohsakaBot
  module CommandLogic
    class Timeout
      def initialize(event, user, duration)
        return if user.nil?

        @event = event
        @member = BOT.member(event.server.id, user)
        @duration = !Integer(duration, exception: false).nil? ? duration.to_i.clamp(30, 60 * 60) : 30
      end

      def run
        return { content: I18n.t(:'commands.tool.admin.timeout.invalid_member') } if @member.nil?

        {
          content: I18n.t(:'commands.tool.admin.timeout.message',
                          member_id: @member.id, duration: @duration, votes: 0),
          components: create_buttons,
          user: @member.id,
          duration: @duration
        }
      end

      def create_buttons
        Discordrb::Components::View.new do |v|
          v.row do |r|
            r.button(style: :primary, label: "✅", custom_id: "timeout:yes")
            r.button(style: :primary, label: "❌", custom_id: "timeout:no")
          end
        end
      end
    end
  end
end
