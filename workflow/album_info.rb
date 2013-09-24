#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'gem_setup.rb')
require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper.rb')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new alfred
  fb = alfred.feedback

  album_info = alfredfm.get_album_information ARGV
  album_tags = AlfredfmHelper.map_information album_info['toptags']['tag'], 'name', 'No Tags!'
      :subtitle   => LocalizationHelper.format_date(album_info['releasedate'], :full),
      :title      => "User Playcount: #{LocalizationHelper.format_number(album_info['userplaycount'])}",
      :subtitle   => "Total Playcount: #{LocalizationHelper.format_number(album_info['playcount'])}",

  image = album_info['image'][1]['content'].split('/')[-1]
  icon_path = AlfredfmHelper.generate_feedback_icon album_info['image'][1]['content'], :volatile_storage_path, image

  releasedate = if !album_info['releasedate'].empty?
    Time.parse(album_info['releasedate']).strftime("%d of %B, %Y")
  else
    'Unknown'
  end

  fb.add_item({
    :uid        => AlfredfmHelper.generate_uuid,
    :title      => album_info['name'],
    :subtitle   => album_info['artist'],
    :arg        => album_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => AlfredfmHelper.generate_uuid,
    :title      => "Release Date",
    :arg        => album_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => AlfredfmHelper.generate_uuid,
    :arg        => album_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => AlfredfmHelper.generate_uuid,
    :title      => "Tags",
    :subtitle   => album_tags,
    :arg        => album_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  puts fb.to_alfred
end
