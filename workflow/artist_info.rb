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
    artist_info = alfredfm.get_artist_information(ARGV)

    band_members = artist_info.get(['bandmembers', 'member']) &&
      AlfredfmHelper.map_information(artist_info['bandmembers']['member'], 'name', nil) ||
      'No known band members.'

    formation_dates = artist_info.get(['bio', 'formationlist', 'formation']) &&
      AlfredfmHelper.get_timestamp_string(artist_info['bio']['formationlist']['formation']) ||
      'No formation dates known.'

    image = artist_info.get(['image', 1, 'content'])
    icon  = image && AlfredfmHelper.generate_feedback_icon(image, :volatile_storage_path, image.split(File::SEPARATOR).last)

    fb.add_item({
      :uid        => artist_info['mbid'],
      :title      => artist_info['name'],
      :subtitle   => band_members,
      :arg        => artist_info['name'],
      :icon       => icon,
      :valid      => 'yes'
    })
    artist_info.get(['bio', 'placeformed']) and
    fb.add_item({
      :uid        => artist_info['mbid'],
      :title      => artist_info['bio']['placeformed'],
      :subtitle   => formation_dates,
      :arg        => artist_info['name'],
      :icon       => icon,
      :valid      => 'yes'
    })
    fb.add_item({
      :uid        => artist_info['mbid'],
      :title      => "User Playcount: #{LocalizationHelper.format_number(artist_info['stats']['userplaycount'])}",
      :subtitle   => "Total Playcount: #{LocalizationHelper.format_number(artist_info['stats']['playcount'])}",
      :arg        => artist_info['name'],
      :icon       => icon,
      :valid      => 'yes'
    })
    artist_info.get(['tags', 'tag']) and
    fb.add_item({
      :uid        => artist_info['mbid'],
      :title      => "Tags",
      :subtitle   => AlfredfmHelper.map_information(artist_info['tags']['tag'], 'name', 'No tags found.'),
      :arg        => artist_info['name'],
      :icon       => icon,
      :valid      => 'yes'
    })

  rescue OSXMediaPlayer::NoTrackPlayingError => e
    AlfredfmHelper.add_error_item(fb, "#{e.to_s}.", 'Type an artist name to look it up on last.fm.')

  rescue Lastfm::ApiError => e
    AlfredfmHelper.add_error_item(fb, "No data found for '#{ARGV.join(' ')}'.", "#{e.to_s.trim('[:cntrl:][:blank:]')}.")
  end

  puts fb.to_alfred
end
