require 'rspec'
require 'helpers/string_helper'
require 'helpers/url_helper'

describe String do
  context 'stripping mass mentions from a string' do
    it 'returns string with no working mass mentions' do
      message = "Let's tag people online @here and offline @everyone".strip_mass_mentions
      expect(message).to eq("Let's tag people online @\u200Bhere and offline @\u200Beveryone")
    end
  end

  context 'sanitizing string from markdown code tags' do
    it 'returns string with flipped markdown code tags' do
      message = "Some `code here` and ```more here```".sanitize_string
      expect(message).to eq("Some ´code here´ and ´´´more here´´´")
    end
  end

  context 'hiding link previews in a message' do
    it 'returns message with link previews disabled' do
      message = "Have you seen this https://example.org and this http://www.example.com/image.jpg".hide_link_preview
      expect(message).to eq("Have you seen this <https://example.org> and this <http://www.example.com/image.jpg>")
    end
  end
end
