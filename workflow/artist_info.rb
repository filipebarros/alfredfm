#!/usr/bin/env ruby
# encoding: utf-8

require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper.rb')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new
  AlfredfmHelper.set_paths alfred.storage_path, alfred.volatile_storage_path
  AlfredfmHelper.load_user_information

  fb = alfred.feedback

  artist_info = alfredfm.get_artist_information

  band_members = AlfredfmHelper.map_information artist_info['bandmembers']['member'], 'name', 'No Band Members!'
  artist_tags = AlfredfmHelper.map_information artist_info['tags']['tag'], 'name', 'No Tags!'

  image = artist_info['image'][1]['content'].split('/')[-1]
  icon_path = AlfredfmHelper.generate_feedback_icon artist_info['image'][1]['content'], :volatile_storage_path, image

  band_time_information = AlfredfmHelper.get_timestamp_string artist_info['bio']['formationlist']['formation']

  begin
  fb.add_item({
    :uid        => '',
    :title      => artist_info['name'],
    :subtitle   => band_members,
    :arg        => artist_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => '',
    :title      => artist_info['bio']['placeformed'],
    :subtitle   => band_time_information,
    :arg        => artist_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => '',
    :title      => "User Playcount: #{AlfredfmHelper.separate_comma(artist_info['stats']['userplaycount'])}",
    :subtitle   => "Total Playcount: #{AlfredfmHelper.separate_comma(artist_info['stats']['playcount'])}",
    :arg        => artist_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => '',
    :title      => "Tags",
    :subtitle   => artist_tags,
    :arg        => artist_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })

  rescue Exception => e
    puts e
  end

  puts fb.to_xml
end
