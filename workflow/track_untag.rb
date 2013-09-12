#!/usr/bin/env ruby
# encoding: utf-8

require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper.rb')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new
  AlfredfmHelper.set_paths alfred.storage_path, alfred.volatile_storage_path
  AlfredfmHelper.load_user_information

  tag_status = alfredfm.untag_track ARGV
  puts tag_status
end