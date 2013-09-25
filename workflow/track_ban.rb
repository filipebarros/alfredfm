#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'gem_setup.rb')
require 'alfred'
Dir.glob(File.join(File.dirname(__FILE__), 'lib', '*.rb')).each {|f| require f }

Alfred.with_friendly_error do |alfred|
    alfredfm = AlfredfmHelper.new alfred
  begin
    track_info = alfredfm.ban_track
    puts track_info

  rescue OSXMediaPlayer::NoTrackPlayingError => e
    fb = alfred.feedback
    AlfredfmHelper.add_error_item(fb, "#{e.to_s}!", 'You can only ban songs playing in iTunes.')
    puts fb.to_alfred
  end
end
