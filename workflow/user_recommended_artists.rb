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
    recommended_artists = alfredfm.get_recommended_artists
    recommended_artists.each do |recommendation|
      image = recommendation.get(['image', 1, 'content'])
      icon  = image && AlfredfmHelper.generate_feedback_icon(image, :volatile_storage_path, image.split(File::SEPARATOR).last);

      fb.add_item({
        :uid        => AlfredfmHelper.generate_uuid,
        :title      => recommendation['name'],
        :subtitle   => "Similar to: #{AlfredfmHelper.map_information(recommendation['context']['artist'], 'name', 'no similar artists found.')}",
        :arg        => recommendation['name'],
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
      :title => 'No recommended artists.',
      :valid => 'no'
    })

  rescue Lastfm::ApiError => e
    AlfredfmHelper.add_error_item(fb, "No data found for '#{ARGV.join(' ')}'.", "#{e.to_s.trim('[:cntrl:][:blank:]')}.")
  end

  puts fb.to_alfred
end
