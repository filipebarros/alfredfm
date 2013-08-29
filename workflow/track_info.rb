#!/usr/bin/env ruby
# encoding: utf-8

require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper.rb')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new
  AlfredfmHelper.set_paths alfred.storage_path, alfred.volatile_storage_path
  AlfredfmHelper.load_user_information

  fb = alfred.feedback

  track_info = alfredfm.get_track_information
  tags = AlfredfmHelper.map_information track_info['toptags']['tag'], 'name', 'No Tags!'

  icon_path = if track_info['album']
    image = track_info['album']['image'][1]['content'].split('/')[-1]
    AlfredfmHelper.generate_feedback_icon track_info['album']['image'][1]['content'], :volatile_storage_path, image
  else
    nil
  end

  fb.add_item({
    :uid        => AlfredfmHelper.generate_uuid,
    :title      => track_info['name'],
    :subtitle   => track_info['artist']['name'],
    :arg        => track_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  if track_info['userloved'].eql? '1'
    fb.add_item({
      :uid        => AlfredfmHelper.generate_uuid,
      :title      => 'Loved',
      :subtitle   => '',
      :arg        => track_info['url'],
      :icon       => icon_path,
      :valid      => 'yes'
    })
  end
  fb.add_item({
    :uid        => AlfredfmHelper.generate_uuid,
    :title      => "User Playcount: #{AlfredfmHelper.separate_comma(track_info['userplaycount'])}",
    :subtitle   => "Total Playcount: #{AlfredfmHelper.separate_comma(track_info['playcount'])}",
    :arg        => track_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => AlfredfmHelper.generate_uuid,
    :title      => "Tags",
    :subtitle   => tags,
    :arg        => track_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })

  puts fb.to_xml(ARGV)
end
