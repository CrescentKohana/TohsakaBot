# Changelog

All notable changes to this project will be documented in this file. Unreleased changes are in the master branch, not just labeled as a true release.

## [Unreleased]
### Added
- Squads Renew: an ability to renew expired Squad invites
- Roll command with button interaction: parses the message (or button interaction) ID for repeating last digits (e.g. 881101126133399**000** )
- SQLite3 support
- Triggerbyid command
- Support for higher upload limits (server boost levels 2 and 3)
- Gem version restraints
- Advanced Rock Paper Scissors command
- Support for message edit events in ASS
- Sextuples roll

### Changed
- Reminder response formatting
- The way ping command calculates latency
- Register command now gives the owner highest permissions (1000)
- The amount of votes is shown to everyone in Polls
- 0 duration enables manual mode in Polls
- Change the way how users who reacted to the call get parsed in Squads. A request to Discord API is no longer needed.
- Refactor and rename permission? method to able?
- Decrease Highlight check overhead
- Refactor Feature requests (Issues) to use SQL
- Refactor Trophy roles to use SQL

### Removed
- Remove "get" keyword from message ID check event
- Polls: remove vote success message
- Remove time and author validations from Squads Mute

### Fixed
- Fix lots of smaller bugs when it comes optional config options
- Fix the offset of the timestamp in repost notifications
- Ignore roles with group_size 0 in Squads
- Author not being correct in renewed Squad calls

## [1.0.0] - 2021/09/17
### Added
- A ton of other features between this and the previous version..
- Polls
- Start CHANGELOG.md

### Changed
- Refactor Squads and Roles

## [0.1.0] - 2019/07/16
### Added
- Open source to GitHub

## [0.0.1] - 2018/06/21
### Added
- Basic reminders
- Initial closed source version

## Info
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
