#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'gem_setup.rb')
require 'alfred'
Dir.glob(File.join(File.dirname(__FILE__), 'lib', '*.rb')).each {|f| require f }

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new alfred
  fb = alfred.feedback
  begin
    similar = alfredfm.get_similar_artists(ARGV)
    similar.each do |artist|
      image   = artist.get(['image', 1, 'content'])
      icon    = image && AlfredfmHelper.generate_feedback_icon(image, :volatile_storage_path, image.split(File::SEPARATOR).last)
      uuid    = similar['mbid'].empty? ? similar['mbid'] : AlfredfmHelper.generate_uuid
      matches = (artist['match'].to_f * 100).precision(2)

      fb.add_item({
        :uid        => uuid,
        :title      => artist['name'],
        :subtitle   => "#{LocalizationHelper.format_number(matches)} % match.",
        :arg        => artist['name'],
        :icon       => icon,
        :valid      => 'yes'
      })
    end

  rescue OSXMediaPlayer::NoTrackPlayingError => e
    AlfredfmHelper.add_error_item(fb, "#{e.to_s}.", 'Type an artist name to look it up on last.fm.')

  rescue Lastfm::ApiError => e
    AlfredfmHelper.add_error_item(fb, "No data found for '#{alfredfm.get_artist}'.", "#{e.to_s.trim('[:cntrl:][:blank:]')}.")
  end

  puts fb.to_alfred
end
