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
    fb.add_item({
      :uid        => '',
      :title      => artist['name'],
      :subtitle   => "#{artist['match'].to_f * 100}% Match",
      :arg        => artist['name'],
      :valid      => 'yes'
    })
  }
  puts fb.to_xml
end
