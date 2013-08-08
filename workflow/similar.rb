#!/usr/bin/env ruby
# encoding: utf-8

require 'alfred'
require 'lastfm'
require 'appscript'

Alfred.with_friendly_error do |alfred|
  fb = alfred.feedback

  it = Appscript.app('iTunes')
  puts it.current_track.artist.get

  lastfm = Lastfm.new(api_key, api_secret)

  # add an feedback to test rescue feedback
  fb.add_item({
    :uid          => ""                     ,
    :title        => "Rescue Feedback Test" ,
    :subtitle     => "rescue feedback item" ,
    :arg          => ""                     ,
    :autocomplete => "failed"               ,
    :valid        => "no"                   ,
  })

  puts fb.to_xml(ARGV)
end



