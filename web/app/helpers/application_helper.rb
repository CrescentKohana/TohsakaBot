# frozen_string_literal: true

module ApplicationHelper
  def current_theme
    session[:style] || 'light'
  end

  def switch_theme
    session[:style] = if current_theme == 'light'
                        'dark'
                      else
                        'light'
                      end
  end
end
