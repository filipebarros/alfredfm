#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'gem_setup.rb')
require 'alfred'
Dir.glob(File.join(File.dirname(__FILE__), 'lib', '*.rb')).each {|f| require f }

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new alfred
  fb = alfred.feedback
  begin
    recommended_events = alfredfm.get_recommended_events
    recommended_events.each do |event|
      event['image'] and
      event['image'][1] and
      event['image'][1]['content'] and
      image = event['image'][1]['content'].split(File::SEPARATOR).last
      icon = image && AlfredfmHelper.generate_feedback_icon(event['image'][1]['content'], :volatile_storage_path, image)

      fb.add_item({
        :uid        => AlfredfmHelper.generate_uuid,
        :title      => "#{event['title']} – #{event['venue']['name']}, #{event['venue']['location']['city']}",
        :subtitle   => "#{LocalizationHelper.format_date(event['startDate'])} – #{Array(event['artists']['artist']).join(', ')}",
        :arg        => "#{event['id']} #{event['title']}",
        :icon       => icon,
        :valid      => 'yes'
      })
    end

    unless fb.empty?
      puts fb.to_alfred(ARGV)
      return
    end

    fb.add_item({
      :uid   => AlfredfmHelper.generate_uuid,
      :title => 'No recommended events.',
      :valid => 'no'
    })

  rescue Lastfm::ApiError => e
    AlfredfmHelper.add_error_item(fb, "No data found for '#{ARGV.join(' ')}'.", "#{e.to_s.trim('[:cntrl:][:blank:]')}.")
  end

  puts fb.to_alfred
end
