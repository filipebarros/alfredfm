#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'gem_setup.rb')
require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper.rb')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new alfred
  fb = alfred.feedback

  user_friends = alfredfm.get_all_friends
  user_friends.each { |friend|
    string_name = AlfredfmHelper.get_friend_name_string friend
    icon_path = AlfredfmHelper.generate_feedback_icon friend['image'][1]['content'], :volatile_storage_path, "#{friend['name']}.png"

      fb.add_item({
        :uid        => AlfredfmHelper.generate_uuid,
        :title      => string_name,
        :subtitle   => "#{LocalizationHelper.format_number(friend['playcount'])} scrobbles",
        :arg        => friend['name'],
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
      :uid => AlfredfmHelper.generate_uuid,
      :title => 'No last.fm friends.',
      :valid => 'no'
    })
  end
  puts fb.to_alfred
end
