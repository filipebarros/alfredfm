#!/usr/bin/env ruby
# encoding: utf-8

require 'alfred'
require 'lastfm'
require 'appscript'
require 'yaml'

def separate_comma(number)
  number.to_s.chars.to_a.reverse.each_slice(3).map(&:join).join(",").reverse
end

Alfred.with_friendly_error do |alfred|
  app_info = YAML.load_file("info.yml")

  api_key = app_info['api_key']
  api_secret = app_info['api_secret']

  fb = alfred.feedback

  it = Appscript.app('iTunes')
  lastfm = Lastfm.new(api_key, api_secret)

  information = YAML.load_file(File.join(alfred.storage_path, 'user_info.yml'))

  user_friends = lastfm.user.get_friends(
    :user => information['username']
  )

  user_friends.each { |friend|
    string_name = if friend['realname'].empty?
      friend['name']
    else
      "#{friend['realname']} - #{friend['name']}"
    end
    icon_path = unless File.exists?(File.join(alfred.volatile_storage_path, "#{friend['name']}.png"))
      if friend['image'][1]['content']
        img = Net::HTTP.get(URI(friend['image'][1]['content']))
        File.write(File.join(alfred.volatile_storage_path, "#{friend['name']}.png"), img)
        { :type => 'default', :name => File.join(alfred.volatile_storage_path, "#{friend['name']}.png") }
      else
        nil
      end
    else
      { :type => "default", :name => File.join(alfred.volatile_storage_path, "#{friend['name']}.png") }
    end

    fb.add_item({
      :uid        => '',
      :title      => string_name,
      :subtitle   => "#{separate_comma(friend['playcount'])} scrobbles",
      :arg        => friend['url'],
      :icon       => icon_path,
      :valid      => 'yes'
    })
  }
  puts fb.to_xml
end
