#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'gem_setup.rb')
require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper.rb')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new alfred

  artist_info = alfredfm.get_artist_information(ARGV) or return nil

  band_members = artist_info['bandmembers'] &&
    AlfredfmHelper.map_information(artist_info['bandmembers']['member'], 'name', nil) ||
    'No known Band members.'

  formation_dates = artist_info['bio']['formationlist'] &&
    artist_info['bio']['formationlist']['formation'] &&
    "#{artist_info['bio']['formationlist']['formation']['yearfrom']}" ||
    'No dates known.'

  image = artist_info['image'][1]['content'].split('/').last
  icon_path = AlfredfmHelper.generate_feedback_icon artist_info['image'][1]['content'], :volatile_storage_path, image
      :title      => "User Playcount: #{LocalizationHelper.format_number(artist_info['stats']['userplaycount'])}",
      :subtitle   => "Total Playcount: #{LocalizationHelper.format_number(artist_info['stats']['playcount'])}",

  fb = alfred.feedback
  fb.add_item({
    :uid        => AlfredfmHelper.generate_uuid,
    :title      => artist_info['name'],
    :subtitle   => band_members,
    :arg        => artist_info['name'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  artist_info['bio'] and
  artist_info['bio']['placeformed'] and
  fb.add_item({
    :uid        => AlfredfmHelper.generate_uuid,
    :title      => artist_info['bio']['placeformed'],
    :subtitle   => formation_dates,
    :arg        => artist_info['name'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => AlfredfmHelper.generate_uuid,
    :arg        => artist_info['name'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  artist_tags = AlfredfmHelper.map_information(artist_info['tags']['tag'], 'name', nil) and
  fb.add_item({
    :uid        => AlfredfmHelper.generate_uuid,
    :title      => "Tags",
    :subtitle   => artist_tags,
    :arg        => artist_info['name'],
    :icon       => icon_path,
    :valid      => 'yes'
  })

  puts fb.to_alfred
end
