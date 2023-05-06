# frozen_string_literal: true

class HighlightsController < ApplicationController
  before_action :tohsakabot_online

  def index
    return unless redirect_if_anonymous

    servers = servers_with_access_to(:highlight_channel)
    @highlights = Highlight.where(server_id: servers)

    respond_to do |format|
      format.html
      format.json { render json: @highlights }
    end
  end

  def show
    return unless redirect_if_anonymous

    @highlight = Highlight.find(params[:id])
    return unless redirect_if_no_discord_perms(@highlight[:server_id], :highlight_channel)

    respond_to do |format|
      format.html
      format.json { render json: @highlight }
    end
  end

  private

  def attachments_as_array(attachments)
    attachments.split
  end

  def attachment_preview(attachment)
    html = if %w[.jpg .png .jpeg .gif .webp].include?(File.extname(attachment).downcase)
             %(<img src="#{attachment}" alt="image attachment" width=400>)
           elsif %w[.mp4 .webm .mov].include?(File.extname(attachment))
             '<video controls width="400">'\
                    "<source src=\"#{attachment}\" type=\"video/#{File.extname(attachment)[1..]}\">"\
                    'Sorry, your browser does not support embedded videos.'\
                    '</video>'
           elsif %w[.wav .flac .ogg .mp3].include?(File.extname(attachment))
             "<audio controls src=\"#{attachment}\">"\
                    'Your browser does not support the audio element.'\
                    '</audio>'
           else
             "<p>Attachment cannot be previewed.</p>"
           end

    html.html_safe
  end

  helper_method :attachments_as_array, :attachment_preview
end
