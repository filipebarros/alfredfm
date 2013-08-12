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
  puts it.current_track.artist.get + '-' + it.current_track.name.get

  lastfm = Lastfm.new(api_key, api_secret)
  token = YAML.load_file(File.join(alfred.storage_path, 'token.yml'))
  puts token['token']
end
