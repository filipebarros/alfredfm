#!/usr/bin/env ruby
# encoding: utf-8

require 'alfred'
require 'lastfm'
require 'appscript'
require 'yaml'

def separate_comma(number)
  number.to_s.chars.to_a.reverse.each_slice(3).map(&:join).join(",").reverse
end

Alfred.with_friendly_error do |alfred|
  app_info = YAML.load_file("info.yml")

  api_key = app_info['api_key']
  api_secret = app_info['api_secret']

  fb = alfred.feedback

  it = Appscript.app('iTunes')
  lastfm = Lastfm.new(api_key, api_secret)

  information = YAML.load_file(File.join(alfred.storage_path, 'user_info.yml'))

  track_info = lastfm.track.get_info(
    :artist => it.current_track.artist.get,
    :track => it.current_track.name.get,
    :username => information['username']
  )

  tags = track_info['toptags']['tag'].map { |pair|
    pair['name']
  }

  fb.add_item({
    :uid        => '',
    :title      => track_info['name'],
    :subtitle   => track_info['artist']['name'],
    :arg        => track_info['url'],
    :valid      => 'yes'
  })
  if track_info['userloved'].eql? '1'
    fb.add_item({
      :uid        => '',
      :title      => 'Loved',
      :subtitle   => '',
      :arg        => track_info['url'],
      :valid      => 'yes'
    })
  end
  fb.add_item({
    :uid        => '',
    :title      => "User Playcount: #{separate_comma(track_info['userplaycount'])}",
    :subtitle   => "Total Playcount: #{separate_comma(track_info['playcount'])}",
    :arg        => track_info['url'],
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => '',
    :title      => "Tags",
    :subtitle   => tags.join(', '),
    :arg        => track_info['url'],
    :valid      => 'yes'
  })

  puts fb.to_xml(ARGV)
end
