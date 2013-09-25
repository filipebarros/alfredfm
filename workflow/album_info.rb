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
    album_info = alfredfm.get_album_information

    icon  = image && AlfredfmHelper.generate_feedback_icon(album_info['image'][1]['content'], :volatile_storage_path, image)

    fb.add_item({
      :uid        => AlfredfmHelper.generate_uuid,
      :title      => album_info['name'],
      :subtitle   => album_info['artist'],
      :arg        => album_info['url'],
      :icon       => icon,
      :valid      => 'yes'
    })
    fb.add_item({
      :uid        => AlfredfmHelper.generate_uuid,
      :title      => "Release Date",
      :subtitle   => LocalizationHelper.format_date(album_info['releasedate'], :full),
      :arg        => album_info['url'],
      :icon       => icon,
      :valid      => 'yes'
    })
    fb.add_item({
      :uid        => AlfredfmHelper.generate_uuid,
      :title      => "User Playcount: #{LocalizationHelper.format_number(album_info['userplaycount'])}",
      :subtitle   => "Total Playcount: #{LocalizationHelper.format_number(album_info['playcount'])}",
      :arg        => album_info['url'],
      :icon       => icon,
      :valid      => 'yes'
    })
    album_tags = AlfredfmHelper.map_information(album_info['toptags']['tag'], 'name', nil) and
    fb.add_item({
      :uid        => AlfredfmHelper.generate_uuid,
      :title      => "Tags",
      :subtitle   => album_tags,
      :arg        => album_info['url'],
      :icon       => icon,
      :valid      => 'yes'
    })

  image = album_info['image'][1]['content'].split('/')[-1]
  rescue OSXMediaPlayer::NoTrackPlayingError => e
    AlfredfmHelper.add_error_item(fb, "#{e.to_s}!", 'Album information lookup only works for the current iTunes track.')

  rescue Lastfm::ApiError => e
    AlfredfmHelper.add_error_item(fb, "No data found for '#{ARGV.join(' ')}'.", "#{e.to_s.trim('[:cntrl:][:blank:]')}.")
  end

  puts fb.to_alfred
end
