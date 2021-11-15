# TohsakaBot
A Discord bot written in Ruby, originally made for a private Discord community. The name comes from one of the main heroines of Fate/stay night, Tohsaka Rin (遠坂凛).

Rails web interface for the bot here: [TohsakaWeb](https://github.com/Luukuton/TohsakaWeb).


## Documentation

### [Changelog](CHANGELOG.md)

### [Commands](documentation/commands.md) (WIP)

### [Functionality](documentation/functionality.md) (WIP)

## Local installation & running
- Enable Privileged Gateway Intents here: `https://discord.com/developers/applications/<id>/bot`
- Install Ruby ([rbenv](https://github.com/rbenv/rbenv) recommended for Linux), and MariaDB/MySQL **or** SQLite3


- **If MariaDB/MySQL**: 
  - Change **TOHSAKABOT_DATABASE_TYPE** in [.env](.env) to `mariadb`.
  - Use these SQL commands to create user and database for the bot. Remember to change USERNAMEs and PASSWORD.
    ```
    CREATE USER 'USERNAME'@'localhost' IDENTIFIED BY 'PASSWORD';
    CREATE DATABASE IF NOT EXISTS tohsaka CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    GRANT ALL PRIVILEGES on tohsaka.* to 'USERNAME'@'localhost';
    FLUSH privileges;
    ```
  - Run the following command in the root dir of the bot to populate the database with tables: `mysql -u USERNAME -p tohsaka < mysql_schema.sql`
- **If SQLite3**:
  - Change **TOHSAKABOT_DATABASE_TYPE** in [.env](.env) to `sqlite`.
  - Run the following command in the root dir of the bot to populate the database with tables: `sqlite3 data/tohsaka.db < sqlite_schema.sql`. The commands found inside `sqlite_schema.sql` can also be executed through SQLite Browser.


- Install bundler: `gem install bundler`
- Run `bundle install` to install required gems.
- _On Windows, if installing the mysql2 gem fails, install it separately with:_
   `gem install mysql2 -- '--with-mysql-lib="C:\devkit\MariaDB 10.5\lib" --with-mysql-include="C:\devkit\MariaDB 10.5\include"'`
- Start the bot by running `bundle exec ruby run.rb`.
- Bot can be invited to a server with the following URL (**remember to change the CLIENT_ID**): 
   `https://discordapp.com/oauth2/authorize?client_id=CLIENT_ID&scope=bot&permissions=335924288`

## Docker
- WIP
- Copy [docker-compose.example.yml](docker-compose.example.yml) as `docker-compose.yml`
- Edit environmentals **TOHSAKABOT_MODE** (`dev`, `test` or `prod`) and **TOHSAKABOT_DATABASE_TYPE** (`sqlite`, `mariadb` or `pgsql`)

## Documentation with YARD
YARD files can be generated with: `yard` command.

They can be viewed by opening `doc/_index.html` in a browser.

## Testing with RSpec
Tests can be performed with `rspec` command.

## Dependencies
* Ruby >= 2.7 supported
* MariaDB / MySQL or SQLite3
* Gems specified in Gemfile (installed by `bundle install`)
  * Using [discordrb](https://github.com/shardlab/discordrb) @ master branch
