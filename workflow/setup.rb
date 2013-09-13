#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'bundler', 'setup.rb')
require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper.rb')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new
  AlfredfmHelper.set_paths alfred.storage_path, alfred.volatile_storage_path

  token = alfredfm.get_token

  user_info = Hash.new
  user_info['username'] = ARGV[0]
  user_info['token'] = token

  alfredfm.open_in_browser token

  begin
    user_info['session'] = alfredfm.get_session token
    AlfredfmHelper.save_hash_to_file :storage_path, 'user_info.yml', user_info
    puts "Authentication Successful!"
  rescue Exception => e
    puts "Authentication Failed!"
  end
end
