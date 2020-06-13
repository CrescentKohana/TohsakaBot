# TohsakaBot
A Discord bot written in Ruby, originally made for a private Discord community. The name comes from one of the main heroines of Fate/stay night, Tohsaka Rin.

Rails web interface for the bot here: [TohsakaWeb](https://github.com/Luukuton/TohsakaWeb).

## Dependencies
* Ruby >= 2.6 supported
* MariaDB / MySQL 
* Gems specified in Gemfile
  * Latest [discordrb](https://github.com/discordrb/discordrb) @ master branch

## Installation & Usage
1. Install Ruby and MariaDB
2. Use these SQL commands to create user and database for the bot. Remember to change USERNAMEs and PASSWORD. 
```
CREATE USER 'USERNAME'@'localhost' IDENTIFIED BY 'PASSWORD';
CREATE DATABASE IF NOT EXISTS tohsaka CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES on tohsaka.* to 'USERNAME'@'localhost';
FLUSH privileges;
```

3. Switch to the root folder of the bot and run `bundle install` to install required gems.
4. Run the `lib/first_time_setup.rb`.
5. Start the bot by running `bundle exec ruby run.rb`.
