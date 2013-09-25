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
    events = alfredfm.get_artist_events(ARGV)
    if events.nil?
      fb.add_item({
        :uid        => AlfredfmHelper.generate_uuid,
        :title      => "No events found for artist #{ARGV.join(' ').trim}!",
        :valid      => 'no'
      })
    else
      events.each do |event|
        event['image'] and
        event['image'][1] and
        event['image'][1]['content'] and
        image = event['image'][1]['content'].split('/').last
        icon = image && AlfredfmHelper.generate_feedback_icon(event['image'][1]['content'], :volatile_storage_path, image)

        fb.add_item({
          :uid        => AlfredfmHelper.generate_uuid,
          :title      => "#{event['title']} – #{event['venue']['name']}, #{event['venue']['location']['city']}",
          :subtitle   => LocalizationHelper.format_date(event['startDate'], :full),
          :arg        => "#{event['id']} #{event['title']}",
          :icon       => icon,
          :valid      => 'yes'
        })
      end
    end

  rescue OSXMediaPlayer::NoTrackPlayingError => e
    AlfredfmHelper.add_error_item(fb, "#{e.to_s}.", 'Type an artist name to look it up on last.fm.')

  rescue Lastfm::ApiError => e
    AlfredfmHelper.add_error_item(fb, "No data found for '#{ARGV.join(' ')}'.", "#{e.to_s.trim('[:cntrl:][:blank:]')}.")
  end
  puts fb.to_alfred
end
