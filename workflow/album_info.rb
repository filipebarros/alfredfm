#!/usr/bin/env ruby
# encoding: utf-8

require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper.rb')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new
  AlfredfmHelper.set_paths alfred.storage_path, alfred.volatile_storage_path
  AlfredfmHelper.load_user_information

  fb = alfred.feedback

  album_info = alfredfm.get_album_information
  album_tags = AlfredfmHelper.map_information album_info['toptags']['tag'], 'name', 'No Tags!'

  image = album_info['image'][1]['content'].split('/')[-1]
  icon_path = AlfredfmHelper.generate_feedback_icon album_info['image'][1]['content'], :volatile_storage_path, image

  fb.add_item({
    :uid        => '',
    :title      => album_info['name'],
    :subtitle   => album_info['artist'],
    :arg        => album_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => '',
    :title      => "Release Date",
    :subtitle   => Time.parse(album_info['releasedate']).strftime("%d of %B, %Y"),
    :arg        => album_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => '',
    :title      => "User Playcount: #{AlfredfmHelper.separate_comma(album_info['userplaycount'])}",
    :subtitle   => "Total Playcount: #{AlfredfmHelper.separate_comma(album_info['playcount'])}",
    :arg        => album_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => '',
    :title      => "Tags",
    :subtitle   => album_tags,
    :arg        => album_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  puts fb.to_xml
end
