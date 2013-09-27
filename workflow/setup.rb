#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'gem_setup.rb')
require 'alfred'
Dir.glob(File.join(File.dirname(__FILE__), 'lib', '*.rb')).each {|f| require f }

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new alfred

  user_info = { :username => ARGV[0], :token => alfredfm.get_token }
  alfredfm.open_in_browser user_info[:token]

  begin
    user_info[:session] = alfredfm.get_session user_info[:token]
    AlfredfmHelper.save_hash_to_file :storage_path, 'user_info.yml', user_info
    puts "Authentication Successful!"
  rescue Exception => e
    puts "Authentication Failed!"
  end
end
