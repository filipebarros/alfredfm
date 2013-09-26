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
    user_friends = alfredfm.get_all_friends
    user_friends.each do |friend|
      name  = AlfredfmHelper.get_friend_name_string friend
      image = friend.get(['image', 1, 'content'])
      icon  = image && AlfredfmHelper.generate_feedback_icon(image, :volatile_storage_path, "#{friend['name']}.png")

      fb.add_item({
        :uid        => AlfredfmHelper.generate_uuid,
        :title      => name,
        :subtitle   => "#{LocalizationHelper.format_number(friend['playcount'] || 0)} scrobbles",
        :arg        => friend['name'],
        :icon       => icon,
        :valid      => 'yes'
      })
    end

    unless fb.items.empty?
      puts fb.to_alfred(ARGV)
      return
    end

    AlfredfmHelper.add_error_item(fb, 'No last.fm friends.')

  rescue Lastfm::ApiError => e
    AlfredfmHelper.add_error_item(fb, "No data found for '#{ARGV.join(' ')}'.", "#{e.to_s.trim('[:cntrl:][:blank:]')}.")
  end

  puts fb.to_alfred
end
