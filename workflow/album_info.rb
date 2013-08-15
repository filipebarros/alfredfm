#!/usr/bin/env ruby
# encoding: utf-8

require 'alfred'
require 'lastfm'
require 'appscript'
require 'yaml'
require 'time'

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

  album_info = lastfm.album.get_info(
    :artist => it.current_track.artist.get,
    :album => it.current_track.album.get,
    :username => information['username']
  )

  album_tags = album_info['toptags']['tag'].map { |pair|
    pair['name']
  }

  fb.add_item({
    :uid        => '',
    :title      => album_info['name'],
    :subtitle   => album_info['artist'],
    :arg        => album_info['url'],
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => '',
    :title      => "Release Date",
    :subtitle   => Time.parse(album_info['releasedate']).strftime("%d of %B, %Y"),
    :arg        => album_info['url'],
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => '',
    :title      => "User Playcount: #{separate_comma(album_info['userplaycount'])}",
    :subtitle   => "Total Playcount: #{separate_comma(album_info['playcount'])}",
    :arg        => album_info['url'],
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => '',
    :title      => "Tags",
    :subtitle   => album_tags.join(', '),
    :arg        => album_info['url'],
    :valid      => 'yes'
  })

  puts fb.to_xml
end
