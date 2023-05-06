# frozen_string_literal: true

class User < ApplicationRecord
  has_many :authorizations
  has_many :reminders
  has_many :triggers
  has_many :issues

  validates :name, :discriminator, :avatar, :locale, presence: true
end
