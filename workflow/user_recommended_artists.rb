#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'gem_setup.rb')
require 'alfred'
Dir.glob(File.join(File.dirname(__FILE__), 'lib', '*.rb')).each {|f| require f }

# custom matcher for alfred-workflow: look for track and artist names
module Alfred
 class Feedback
   class Item
     alias_method :default_match?, :match?
     def match? query
       title_and_subtitle_match?(query)
     end
   end
 end
end

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new alfred
  fb = alfred.feedback

  recommended_artists = alfredfm.get_recommended_artists
  recommended_artists.each { |recommendation|
    image = recommendation['image'][1]['content'].split('/')[-1]
    icon_path = AlfredfmHelper.generate_feedback_icon recommendation['image'][1]['content'], :volatile_storage_path, image

    similar = AlfredfmHelper.map_information recommendation['context']['artist'], 'name', 'No Similar Artists!'
    unless fb.empty?
      puts fb.to_alfred(ARGV)
      return
    end

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
