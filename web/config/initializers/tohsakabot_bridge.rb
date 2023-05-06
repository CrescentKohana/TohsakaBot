# frozen_string_literal: true

require 'drb/drb'

SERVER_URI = "druby://localhost:8787"
DRb.start_service
