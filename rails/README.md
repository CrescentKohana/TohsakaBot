# TohsakaWeb
An optional Ruby on Rails web frontend for TohsakaBot.

## Usage
- Setup [bot](../bot).
- Install everything by first running
   `bundle install` and then `npm i`.
- Copy [config/user_config.example.yml](config/user_config.example.yml) as `config/user_config.yml`. Now enter the web host (eg. rin.domain.com), path to TohsakaBot (eg. /home/rin/TohsakaBot) and Discord ID of the owner to there.
- If you haven't already done so, enter Discord credentials to config/credentials.ymc.enc with the following command **on Linux**:
    ```
    EDITOR="nano" rails credentials:edit
    ```
  or **on Windows**:
    ```
    $env:EDITOR="notepad"
    rails credentials:edit
    ```
- **Production**
  - [Recommended] Setup NGINX. Example config with SSL for TohsakaWeb [here](../documentation/tohsakaweb_nginx.conf).
  - Precompile assets with `rails assets:precompile`
  - Start the app `bundle exec puma -b unix://tmp/server.sock`
- **Development**
  - Start the app `RAILS_ENV=development bundle exec puma -b unix://tmp/server.sock`

## Dependencies
* Web server (NGINX recommended)
* Ruby >= 3.0 supported
* MariaDB (with libmysqlclient-dev) or SQLite (with libsqlite3-dev)
* Node.js (14.5.0+)
