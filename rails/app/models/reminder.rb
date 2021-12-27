# frozen_string_literal: true

class Reminder < ApplicationRecord
  belongs_to :user

  attr_accessor :repeat_day, :repeat_hour, :repeat_min

  validates :datetime, presence: true
  validates :channel_id, presence: true, numericality: { only_integer: true }
  validates :repeat, allow_nil: true, numericality: { only_integer: true, accept: { greater_than: 600, equal_to: 0 } }

  validate :repeat_interval_as_seconds

  private

  def repeat_interval_as_seconds
    minutes = repeat_min.to_i
    hours = repeat_hour.to_i
    days = repeat_day.to_i

    if minutes.negative? || hours.negative? || days.negative?
      errors.add(:base, "Negative values aren't allowed.")
    else
      seconds = (minutes * 60) + (hours * 60 * 60) + (days * 24 * 60 * 60)
      errors.add(:base, "Interval has to be 12 hours or more.") if !seconds.zero? && (seconds < 43_200)
    end
  end
end
