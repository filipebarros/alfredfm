#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'gem_setup.rb')
require 'alfred'
Dir.glob(File.join(File.dirname(__FILE__), 'lib', '*.rb')).each {|f| require f }

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new alfred
  fb = alfred.feedback
        :subtitle   => "#{LocalizationHelper.format_date(event['startDate'])} – #{Array(event['artists']['artist']).join(', ')}",

  recommended_events = alfredfm.get_recommended_events
  recommended_events.each { |event|
    image = event['image'][1]['content'].split('/')[-1]
    unless fb.empty?
      puts fb.to_alfred(ARGV)
      return
    end

    fb.add_item({
      :uid        => AlfredfmHelper.generate_uuid,
      :title      => "#{event['title']} - #{event['venue']['name']}, #{event['venue']['location']['city']}",
      :arg        => "#{event['id']} #{event['title']}",
      :icon       => icon_path,
      :valid      => 'yes'
    })
  }
  puts fb.to_alfred
end
