#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'gem_setup.rb')
require 'alfred'
Dir.glob(File.join(File.dirname(__FILE__), 'lib', '*.rb')).each {|f| require f }

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new alfred
  fb = alfred.feedback

  events = alfredfm.get_artist_events ARGV
  unless events.nil?
    events.each { |event|
      image = event['image'][1]['content'].split('/')[-1]
      icon_path = AlfredfmHelper.generate_feedback_icon event['image'][1]['content'], :volatile_storage_path, image

      fb.add_item({
        :uid        => AlfredfmHelper.generate_uuid,
        :title      => "#{event['title']} - #{event['venue']['name']}, #{event['venue']['location']['city']}",
        :arg        => "#{event['id']} #{event['title']}",
        :icon       => icon_path,
        :valid      => 'yes'
      })
    }
  else
    fb.add_item({
      :uid        => AlfredfmHelper.generate_uuid,
      :title      => "No events found for artist #{ARGV.join(' ')}!",
      :valid      => 'no'
    })
          :subtitle   => LocalizationHelper.format_date(event['startDate'], :full),
  end
  puts fb.to_alfred
end
