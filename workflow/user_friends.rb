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
      name_string = AlfredfmHelper.get_friend_name_string friend
      fb.add_item({
        :uid        => AlfredfmHelper.generate_uuid,
        :title      => name_string,
        :subtitle   => "#{LocalizationHelper.format_number(friend['playcount'])} scrobbles",
        :arg        => friend['name'],
        :icon       => AlfredfmHelper.generate_feedback_icon(friend['image'][1]['content'], :volatile_storage_path, "#{friend['name']}.png"),
        :valid      => 'yes'
      })
    end

    unless fb.items.empty?
      puts fb.to_alfred(ARGV)
      return
    end

    fb.add_item({
      :uid => AlfredfmHelper.generate_uuid,
      :title => 'No last.fm friends.',
      :valid => 'no'
    })

  rescue Lastfm::ApiError => e
    AlfredfmHelper.add_error_item(fb, "No data found for '#{ARGV.join(' ')}'.", "#{e.to_s.trim('[:cntrl:][:blank:]')}.")
  end
  puts fb.to_alfred
end
