# encoding: utf-8

require File.join(File.dirname(__FILE__), 'bundle', 'bundler', 'setup.rb')
require 'alfred'
Dir.glob(File.join(File.dirname(__FILE__), 'lib', '*.rb')).each { |f| require f }

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new alfred

  action = ARGV.shift.to_sym
  arguments = ARGV.join(' ')
  begin
    track_info = alfredfm.track_action action, arguments
    puts track_info
  rescue OSXMediaPlayer::NoTrackPlayingError => e
    fb = alfred.feedback
    AlfredfmHelper.add_error_item(fb, "#{e.to_s}!", 'You can only love songs playing in iTunes.')
    puts fb.to_alfred
  end
end
