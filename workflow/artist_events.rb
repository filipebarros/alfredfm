# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'bundler', 'setup')
require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new(alfred.storage_path, alfred.volatile_storage_path)
  fb = alfred.feedback

  events = alfredfm.get_artist_events ARGV
  if events.nil?
    fb.add_item({
      :uid        => AlfredfmHelper.generate_uuid,
      :title      => "No events found for artist #{ARGV.join(' ')}!",
      :valid      => 'no'
    })
  else
    events.each do |event|
      image = event['image'][1]['content'].split('/')[-1]
      icon_path = alfredfm.generate_feedback_icon event['image'][1]['content'], :volatile_storage_path, image

      fb.add_item({
        :uid        => AlfredfmHelper.generate_uuid,
        :title      => "#{event['title']} - #{event['venue']['name']}, #{event['venue']['location']['city']}",
        :subtitle   => event['startDate'],
        :arg        => "#{event['id']} #{event['title']}",
        :icon       => icon_path,
        :valid      => 'yes'
      })
    end
  end
  puts fb.to_alfred
end
