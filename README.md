# TohsakaBot
A Discord bot written in Ruby, originally made for a private Discord community. The name comes from one of the main heroines of Fate/stay night, Tohsaka Rin (遠坂凛).

## Documentation

### [Rails Web](rails) (optional)

### [Changelog](CHANGELOG.md)

### [Commands](documentation/commands.md) (WIP)

### [Functionality](documentation/functionality.md) (WIP)

## Local installation & running
- Enable Privileged Gateway Intents here: `https://discord.com/developers/applications/<id>/bot`
- Install Ruby ([rbenv](https://github.com/rbenv/rbenv) recommended for Linux), and MariaDB/MySQL **or** SQLite3
- Install bundler: `gem install bundler`
- Run `cd web && bundle install` and `cd ../bot && bundle install` to install required gems.
  - _On Windows, if installing the mysql2 gem fails, install it separately with:_
    `gem install mysql2 -- '--with-mysql-lib="C:\pathto\MariaDB 10.5\lib" --with-mysql-include="C:\pathto\MariaDB 10.5\include"'`
- Enter Discord and database credentials to config/credentials.ymc.enc with the following command **on Linux**:
  ```
  EDITOR="nano" rails credentials:edit
  ```
  or **on Windows**:
  ```
  $env:EDITOR="notepad"
  rails credentials:edit
  ```
  Contents example:
  ```
  secret_key_base: xxxxx
  jwt_secret: JWTSECRET
  discord:
    client_id: '000000000000000000'
    secret: 'BOTSECRET'
  mysql:
    username: 'USERNAME'
    password: 'PASSWORD'
  ```
- Database setup
  - **MariaDB/MySQL**
    - Use these SQL commands to create user and database for the bot. Remember to change USERNAMEs and PASSWORD.
      ```
      CREATE USER 'USERNAME'@'localhost' IDENTIFIED BY 'PASSWORD';
      CREATE DATABASE IF NOT EXISTS tohsaka CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
      GRANT ALL PRIVILEGES on tohsaka.* to 'USERNAME'@'localhost';
      FLUSH privileges;
      ```
    - Run `rails db:migrate RAILS_ENV=prodmysql`
  - **SQLite3**
    - Run `rails db:migrate RAILS_ENV=prodsqlite`
- Start the bot with `bundle exec ruby run.rb`.
- Bot can be invited to a server with the following URL (change the CLIENT_ID): 
   `https://discordapp.com/oauth2/authorize?client_id=CLIENT_ID&scope=bot&permissions=335924288`

## Docker (WIP)
- ~~Copy [docker-compose.example.yml](docker-compose.example.yml) as `docker-compose.yml`~.~~
- ~~Edit environmentals **TOHSAKABOT_MODE** (`dev`, `test` or `prod`) and **TOHSAKABOT_DATABASE_TYPE** (`sqlite`, `mariadb` or `pgsql`)~~

## Documentation with YARD
YARD files can be generated with: `yard` command.

They can be viewed by opening `doc/_index.html` in a browser.

## Testing with RSpec
Tests can be performed with `rspec` command.

## Dependencies
* Ruby >= 3.0 supported
* MariaDB / MySQL or SQLite3
* Gems specified in Gemfile
  * Using [discordrb](https://github.com/shardlab/discordrb) @ main branch
