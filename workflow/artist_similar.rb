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
      artist['image'] and
      artist['image'][1] and
      artist['image'][1]['content'] and
      image = artist['image'][1]['content'].split('/').last
      icon = image && AlfredfmHelper.generate_feedback_icon(artist['image'][1]['content'], :volatile_storage_path, image)

      rounded = sprintf('%.2f', artist['match']).to_f

      fb.add_item({
        :uid        => AlfredfmHelper.generate_uuid,
        :title      => artist['name'],
        :subtitle   => "#{rounded * 100} % Match",
        :arg        => artist['name'],
        :icon       => icon,
        :valid      => 'yes'
      })
    end

  rescue OSXMediaPlayer::NoTrackPlayingError => e
    AlfredfmHelper.add_error_item(fb, "#{e.to_s}.", 'Type an artist name to look it up on last.fm.')

  rescue Lastfm::ApiError => e
    AlfredfmHelper.add_error_item(fb, "No data found for '#{ARGV.join(' ')}'.", "#{e.to_s.trim('[:cntrl:][:blank:]')}.")
  end
  puts fb.to_alfred
end
