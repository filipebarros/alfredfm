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

  information = YAML.load_file(File.join(alfred.storage_path, 'user_info.yml'))

  begin
    lastfm.session = lastfm.auth.get_session(:token => information['token'])['key']
    lastfm.track.love(:artist => it.current_track.artist.get, :track => it.current_track.name.get)
    puts "Successfully Loved #{it.current_track.name.get} by #{it.current_track.artist.get}!"
  rescue Exception => e
    puts "Unsuccessful!"
  end
end
