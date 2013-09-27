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
  begin
    loved_tracks = alfredfm.get_loved_tracks
    loved_tracks.each do |track|
      image = track.get(['image', 1, 'content'])
      icon  = image && AlfredfmHelper.generate_feedback_icon(image, :volatile_storage_path, image.split(File::SEPARATOR).last)
      uuid  = track['mbid'].empty? ? track['mbid'] : AlfredfmHelper.generate_uuid
      info  = track['artist']['name']
      info << " – #{LocalizationHelper.format_date(track['date']['content'], :full)}." unless track.get(['date', 'content']).empty?

      fb.add_item({
        :uid      => uuid,
        :title    => track['name'],
        :subtitle => info,
        :arg      => track['url'],
        :icon     => icon,
        :valid    => 'yes'
      })
    end

    unless fb.items.empty?
      puts fb.to_alfred(ARGV)
      return
    end

   AlfredfmHelper.add_error_item(fb, 'No loved tracks.')

  rescue Lastfm::ApiError => e
    AlfredfmHelper.add_error_item(fb, "No data found for '#{ARGV.join(' ')}'.", "#{e.to_s.trim('[:cntrl:][:blank:]')}.")
  end

  puts fb.to_alfred
end
