#!/usr/bin/env ruby
# encoding: utf-8

require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper.rb')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new
  AlfredfmHelper.set_paths alfred.storage_path, alfred.volatile_storage_path
  AlfredfmHelper.load_user_information

  fb = alfred.feedback

  user_friends = alfredfm.get_all_friends
  user_friends.each { |friend|
    string_name = AlfredfmHelper.get_friend_name_string friend
    icon_path = AlfredfmHelper.generate_feedback_icon friend['image'][1]['content'], :volatile_storage_path, "#{friend['name']}.png"

    fb.add_item({
      :uid        => '',
      :title      => string_name,
      :subtitle   => "#{AlfredfmHelper.separate_comma(friend['playcount'])} scrobbles",
      :arg        => friend['url'],
      :icon       => icon_path,
      :valid      => 'yes'
    })
  }
  puts fb.to_xml
end
