# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'bundler', 'setup')
require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new(alfred.storage_path, alfred.volatile_storage_path)
  fb = alfred.feedback

  recommended_events = alfredfm.get_recommendations :events
  recommended_events.each do |event|
    image = event['image'][1]['content'].split('/')[-1]
    icon_path = alfredfm.generate_feedback_icon event['image'][1]['content'], :volatile_storage_path, image

    AlfredfmHelper.add_event event, icon_path, fb
  end
  puts fb.to_alfred
end
