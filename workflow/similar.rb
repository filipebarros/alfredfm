#!/usr/bin/env ruby
# encoding: utf-8

require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper.rb')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new
  AlfredfmHelper.set_paths alfred.storage_path, alfred.volatile_storage_path
  AlfredfmHelper.load_user_information

  fb = alfred.feedback

  similar = alfredfm.get_similar_artists
  similar.each { |artist|
    image = artist['image'][1]['content'].split('/')[-1]
    icon_path = AlfredfmHelper.generate_feedback_icon artist['image'][1]['content'], :volatile_storage_path, image

    rounded = sprintf('%.2f', artist['match']).to_f

    fb.add_item({
      :uid        => AlfredfmHelper.generate_uuid,
      :title      => artist['name'],
      :subtitle   => "#{rounded * 100}% Match",
      :arg        => artist['name'],
      :icon       => icon_path,
      :valid      => 'yes'
    })
  }
  puts fb.to_xml
end
