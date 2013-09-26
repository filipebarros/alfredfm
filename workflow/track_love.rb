# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'bundler', 'setup')
require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new(alfred.storage_path, alfred.volatile_storage_path)

  track_info = alfredfm.love_track
  puts track_info
end
