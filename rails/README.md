# TohsakaWeb
An optional Ruby on Rails web frontend for TohsakaBot.

## Usage
- Setup [bot](../bot).
- Install everything by first running
   `bundle install` and then `npm install`.
- Copy [config/user_config.example.yml](config/user_config.example.yml) as `config/user_config.yml`. Now enter the webhost (eg. rin.domain.com), path to TohsakaBot (eg. /home/rin/TohsakaBot) and Discord ID of the owner to there.
- Enter Discord and SQL database credentials to config/credentials.ymc.enc with the following command: 
   
   ```
   EDITOR="nano" rails credentials:edit
   ```
- Setup database: `rails db:migrate`
- **Production**
  - Setup NGINX. Example config with SSL for TohsakaWeb [here](../documentation/tohsakaweb_nginx.conf).
  - Precompile assets with `rails assets:precompile`
  - Start the app `bundle exec puma -b unix://tmp/server.sock`
- **Development**
  - Start the app `RAILS_ENV=development bundle exec puma -b unix://tmp/server.sock`

## Dependencies
* Web server (NGINX recommended)
* Ruby >= 3.0 supported
* MariaDB, PostgreSQL or SQLite
* Node.js (14.5.0+)
* libmysqlclient-dev
