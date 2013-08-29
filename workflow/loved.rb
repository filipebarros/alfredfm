#!/usr/bin/env ruby
# encoding: utf-8

require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper.rb')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new
  AlfredfmHelper.set_paths alfred.storage_path, alfred.volatile_storage_path
  AlfredfmHelper.load_user_information

  fb = alfred.feedback
  loved_tracks = alfredfm.get_loved_tracks
  loved_tracks.each { |track|
    icon_path = if track['image']
      image = track['image'][1]['content'].split('/')[-1]
      AlfredfmHelper.generate_feedback_icon track['image'][1]['content'], :volatile_storage_path, image
    end

    fb.add_item({
      :uid        => AlfredfmHelper.generate_uuid,
      :title      => track['name'],
      :subtitle   => track['artist']['name'],
      :arg        => track['url'],
      :icon       => icon_path,
      :valid      => 'yes'
    })
  }
  puts fb.to_xml
end