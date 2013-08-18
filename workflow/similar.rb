#!/usr/bin/env ruby
# encoding: utf-8

require 'alfred'
require 'lastfm'
require 'appscript'
require 'yaml'

Alfred.with_friendly_error do |alfred|
  app_info = YAML.load_file("info.yml")

  api_key = app_info['api_key']
  api_secret = app_info['api_secret']

  fb = alfred.feedback

  it = Appscript.app('iTunes')
  lastfm = Lastfm.new(api_key, api_secret)

  similar = lastfm.artist.get_similar(:artist => it.current_track.artist.get)
  similar.shift
  similar.each { |artist|
    image = artist['image'][1]['content'].split('/')[-1]
    icon_path = unless File.exists?(File.join(alfred.volatile_storage_path, image))
      if artist['image'][1]['content']
        img = Net::HTTP.get(URI(artist['image'][1]['content']))
        File.write(File.join(alfred.volatile_storage_path, image), img)
        { :type => 'default', :name => File.join(alfred.volatile_storage_path, image) }
      else
        nil
      end
    else
      { :type => "default", :name => File.join(alfred.volatile_storage_path, image) }
    end
    fb.add_item({
      :uid        => '',
      :title      => artist['name'],
      :subtitle   => "#{artist['match'].to_f * 100}% Match",
      :arg        => artist['name'],
      :icon       => icon_path,
      :valid      => 'yes'
    })
  }
  puts fb.to_xml
end
