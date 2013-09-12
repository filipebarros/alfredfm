#!/usr/bin/env ruby
# encoding: utf-8

require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper.rb')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new
  AlfredfmHelper.set_paths alfred.storage_path, alfred.volatile_storage_path
  AlfredfmHelper.load_user_information

  fb = alfred.feedback

  recommended_events = alfredfm.get_recommended_events
  recommended_events.each { |event|
    image = event['image'][1]['content'].split('/')[-1]
    icon_path = AlfredfmHelper.generate_feedback_icon event['image'][1]['content'], :volatile_storage_path, image

    fb.add_item({
      :uid        => AlfredfmHelper.generate_uuid,
      :title      => "#{event['title']} - #{event['venue']['name']}, #{event['venue']['location']['city']}",
      :subtitle   => AlfredfmHelper.convert_array_to_string(event['artists']['artist']),
      :arg        => "#{event['id']} #{event['title']}",
      :icon       => icon_path,
      :valid      => 'yes'
    })
  }
  puts fb.to_alfred
end