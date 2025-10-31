# frozen_string_literal: true

require 'rspec'
require 'action_view'
require 'active_support/core_ext/numeric/time'
require 'active_support/time_with_zone'
require 'commands/logic/reminder/reminder_controller'
require 'commands/logic/reminder/reminder_handler'
require 'helpers/time_helper'

describe TohsakaBot::ReminderController do
  context 'parsing duration' do
    it 'returns a proper timestamp' do
      rem = TohsakaBot::ReminderController.new(nil, 1, false, '1y2M4d1h30m10s')
      got = rem.convert_datetime(Time.new('2023-01-01 12:00:00'))
      want = Time.new('2024-03-05 13:30:10')
      expect(got).to eq(want)
    end
  end

  context 'parsing ISO 8601' do
    it 'returns a proper timestamp' do
      rem = TohsakaBot::ReminderController.new(nil, 1, false, '2023-06-12_15:33:15')
      got = rem.convert_datetime
      want = Time.new('2023-06-12 15:33:15')
      expect(got).to eq(want)
    end
  end

  context 'parsing natural language #1' do
    it 'returns a proper timestamp' do
      rem = TohsakaBot::ReminderController.new(nil, 1, false, 'in 3 months')
      got = rem.convert_datetime(Time.new('2023-01-01 12:00:00'))
      want = Time.new('2023-04-01 12:00:00')
      expect(got).to eq(want)
    end
  end

  context 'parsing natural language #2' do
    it 'returns a proper timestamp' do
      rem = TohsakaBot::ReminderController.new(nil, 1, false, 'next week sunday night')
      got = rem.convert_datetime(Time.new('2023-01-01 12:00:00'))
      want = Time.new('2023-01-15 22:00:00')
      expect(got).to eq(want)
    end
  end
end
