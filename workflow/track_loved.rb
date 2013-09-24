#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'gem_setup.rb')
require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper.rb')

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
    end
  }

    unless fb.items.empty?
      puts fb.to_alfred(ARGV)
      return
    end
    fb.add_item({
      :uid   => AlfredfmHelper.generate_uuid,
      :title => 'No loved tracks.',
      :valid => 'no'
    })
  end
  puts fb.to_alfred
end
