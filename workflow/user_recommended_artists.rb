#!/usr/bin/env ruby
# encoding: utf-8

require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper.rb')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new
  AlfredfmHelper.set_paths alfred.storage_path, alfred.volatile_storage_path
  AlfredfmHelper.load_user_information

  fb = alfred.feedback

  recommended_artists = alfredfm.get_recommended_artists
  recommended_artists.each { |recommendation|
    image = recommendation['image'][1]['content'].split('/')[-1]
    icon_path = AlfredfmHelper.generate_feedback_icon recommendation['image'][1]['content'], :volatile_storage_path, image

    similar = AlfredfmHelper.map_information recommendation['context']['artist'], 'name', 'No Similar Artists!'

    fb.add_item({
      :uid        => AlfredfmHelper.generate_uuid,
      :title      => recommendation['name'],
      :subtitle   => similar,
      :arg        => recommendation['name'],
      :icon       => icon_path,
      :valid      => 'yes'
    })
  }
  puts fb.to_alfred
end
