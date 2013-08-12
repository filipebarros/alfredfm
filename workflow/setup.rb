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

  `open "http://www.last.fm/api/auth/?api_key=#{api_key}&token=#{token}"`
  sleep 15

  begin
    lastfm.auth.get_session(:token => token)['key']
    File.open(File.join(alfred.storage_path, 'token.yml'), "w") { |file|
      file.write("token:#{token}")
    }
    puts "Authentication Successful!"
  rescue Exception => e
    puts "Authentication Failed!"
  end
end
