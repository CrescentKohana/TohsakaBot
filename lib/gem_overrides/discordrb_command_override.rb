module Discordrb::Commands
  class Command
    def initialize(name, attributes = {}, &block)
      @name = name
      @attributes = {
          permission_level: attributes[:permission_level] || 0,
          permission_message: attributes[:permission_message].is_a?(FalseClass) ? nil : (attributes[:permission_message] || "You don't have permission to execute command %name%!"),
          required_permissions: attributes[:required_permissions] || [],
          required_roles: attributes[:required_roles] || [],
          allowed_roles: attributes[:allowed_roles] || [],
          channels: attributes[:channels] || nil,
          chain_usable: attributes[:chain_usable].nil? ? true : attributes[:chain_usable],
          help_available: attributes[:help_available].nil? ? true : attributes[:help_available],
          description: attributes[:description] || nil,
          usage: attributes[:usage] || nil,
          arg_types: attributes[:arg_types] || nil,
          parameters: attributes[:parameters] || nil,
          min_args: attributes[:min_args] || 0,
          max_args: attributes[:max_args] || -1,
          rate_limit_message: attributes[:rate_limit_message],
          bucket: attributes[:bucket],
          rescue: attributes[:rescue],
          aliases: attributes[:aliases] || [],

          # Additions
          require_register: attributes[:require_register] || false,
          enabled_in_pm: attributes[:require_register] || true,
      }

      @block = block
    end

    def call(event, arguments, chained = false, check_permissions = true)
      if @attributes[:require_register] == true
        return unless TohsakaBot.registered?(event.author.id, event)
      end

      if @attributes[:enabled_in_pm] == false
        return if event.channel.pm?
      end

      if arguments.length < @attributes[:min_args]
        response = "Too few arguments for command `#{name}`!"
        response += "\nUsage: `#{@attributes[:usage]}`" if @attributes[:usage]
        event.respond(response)
        return
      end
      if @attributes[:max_args] >= 0 && arguments.length > @attributes[:max_args]
        response = "Too many arguments for command `#{name}`!"
        response += "\nUsage: `#{@attributes[:usage]}`" if @attributes[:usage]
        event.respond(response)
        return
      end
      unless @attributes[:chain_usable]
        if chained
          event.respond "Command `#{name}` cannot be used in a command chain!"
          return
        end
      end

      if check_permissions
        rate_limited = event.bot.rate_limited?(@attributes[:bucket], event.author)
        if @attributes[:bucket] && rate_limited
          event.respond @attributes[:rate_limit_message].gsub('%time%', rate_limited.round(2).to_s) if @attributes[:rate_limit_message]
          return
        end
      end

      result = @block.call(event, *arguments)
      event.drain_into(result)
    rescue LocalJumpError => e # occurs when breaking
      result = e.exit_value
      event.drain_into(result)
    rescue StandardError => e # Something went wrong inside our @block!
      rescue_value = @attributes[:rescue] || event.bot.attributes[:rescue]
      if rescue_value
        event.respond(rescue_value.gsub('%exception%', e.message)) if rescue_value.is_a?(String)
        rescue_value.call(event, e) if rescue_value.respond_to?(:call)
      end

      raise e
    end
  end
end
