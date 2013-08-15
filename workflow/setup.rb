#!/usr/bin/env ruby
# encoding: utf-8

require 'alfred'
require 'lastfm'
require 'yaml'

Alfred.with_friendly_error do |alfred|
  app_info = YAML.load_file("info.yml")

  api_key = app_info['api_key']
  api_secret = app_info['api_secret']

  lastfm = Lastfm.new(api_key, api_secret)
  token = lastfm.auth.get_token

  user_info = Hash.new
  user_info['username'] = ARGV[0]
  user_info['token'] = token

  `open "http://www.last.fm/api/auth/?api_key=#{api_key}&token=#{token}"`
  sleep 15

  begin
    user_info['sesssion'] = lastfm.auth.get_session(:token => token)['key']
    File.write(File.join(alfred.storage_path, 'user_info.yml'), user_info.to_yaml)
    puts "Authentication Successful!"
  rescue Exception => e
    puts "Authentication Failed!"
  end
end
