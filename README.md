# TohsakaBot
A Discord bot written in Ruby, originally made for a private Discord community. The name comes from one of the main heroines of Fate/stay night, Tohsaka Rin.

Rails web interface for the bot here: [TohsakaWeb](https://github.com/Luukuton/TohsakaWeb).

## Installation & Running
1. Make sure dependencies below are all met.
2. Install Ruby and MariaDB
3. Use these SQL commands to create user and database for the bot. Remember to change USERNAMEs and PASSWORD. 
```
CREATE USER 'USERNAME'@'localhost' IDENTIFIED BY 'PASSWORD';
CREATE DATABASE IF NOT EXISTS tohsaka CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES on tohsaka.* to 'USERNAME'@'localhost';
FLUSH privileges;
```

4. Switch to the root folder of the bot and run `bundle install` to install required gems.
5. Run the `lib/first_time_setup.rb`.
6. Start the bot by running `bundle exec ruby run.rb`.
7. Bot can be invited to a server with the following URL (**remember to change the CLIENT_ID**): 
```
https://discordapp.com/oauth2/authorize?client_id=CLIENT_ID&scope=bot&permissions=335924288
```

## Documentation with YARD
YARD files can be generated with: `yard` command.

They can be viewed by opening `doc/_index.html` in a browser.

## Testing with RSpec
Tests can be performed with `rspec` command.

## Dependencies
* Ruby >= 2.6 supported
* MariaDB / MySQL 
* Gems specified in Gemfile (installed by `bundle install`)
  * Latest [discordrb](https://github.com/discordrb/discordrb) @ master branch
