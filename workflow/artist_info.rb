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

  artist_info = lastfm.artist.get_info(
    :artist => it.current_track.artist.get,
    :username => information['username']
  )

  band_members = artist_info['bandmembers']['member'].map { |member|
    member['name'].strip
  }

  artist_tags = artist_info['tags']['tag'].map { |tag|
    tag['name']
  }

  image = artist_info['image'][1]['content'].split('/')[-1]
  icon_path = unless File.exists?(File.join(alfred.volatile_storage_path, image))
    if artist_info['image'][1]['content']
      img = Net::HTTP.get(URI(artist_info['image'][1]['content']))
      File.write(File.join(alfred.volatile_storage_path, image), img)
      { :type => 'default', :name => File.join(alfred.volatile_storage_path, image) }
    else
      nil
    end
  else
    { :type => "default", :name => File.join(alfred.volatile_storage_path, image) }
  end

  band_dates = if artist_info['bio']['formationlist']['formation']['yearto'].empty?
    "#{artist_info['bio']['formationlist']['formation']['yearfrom']} to Present"
  else
    "#{artist_info['bio']['formationlist']['formation']['yearfrom']} to #{artist_info['bio']['formationlist']['formation']['yearto']}"
  end

  fb.add_item({
    :uid        => '',
    :title      => artist_info['name'],
    :subtitle   => band_members.join(', '),
    :arg        => artist_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => '',
    :title      => artist_info['bio']['placeformed'],
    :subtitle   => band_dates,
    :arg        => artist_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => '',
    :title      => "User Playcount: #{separate_comma(artist_info['stats']['userplaycount'])}",
    :subtitle   => "Total Playcount: #{separate_comma(artist_info['stats']['playcount'])}",
    :arg        => artist_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })
  fb.add_item({
    :uid        => '',
    :title      => "Tags",
    :subtitle   => artist_tags.join(', '),
    :arg        => artist_info['url'],
    :icon       => icon_path,
    :valid      => 'yes'
  })

  puts fb.to_xml
end
