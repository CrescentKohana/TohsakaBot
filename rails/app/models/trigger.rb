# frozen_string_literal: true

class Trigger < ApplicationRecord
  belongs_to :user

  validates :phrase, presence: true
  validates :mode, presence: true
  validates :server_id, presence: true
  validates :chance, numericality: { only_integer: true, more_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  validate :reply_and_file_blank

  mount_uploader :file, FileUploader
  validates :file, file_size: { less_than: 8.megabytes }

  private

  def reply_and_file_blank
    errors.add(:base, "Specify a reply or a file, not both") if !reply.blank? && !file.filename.nil?
  end
end
