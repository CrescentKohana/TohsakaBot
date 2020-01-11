module TohsakaBot
  module Commands
    module ExclusionUrl
      extend Discordrb::Commands::CommandContainer
      command(:excludeurl,
              aliases: %i[urlexclude],
              description: 'Excludes an url from the link list.',
              usage: 'excludeurl <url/regex>',
              min_args: 1,
              required_permissions: %i[manage_server],
              rescue: "Something went wrong!\n`%exception%`") do |event, u|

        exclusions = YAML::Store.new('data/excluded_urls.yml')
        exclusions.transaction do
          i = 1
          i += 1 while exclusions.root?(i)
          exclusions[i] = {"url" => u.to_s}
          exclusions.commit
        end
        $excluded_urls = YAML.load_file('data/excluded_urls.yml')
        event.<< 'Exclusion added.'
      end
    end
  end
end
