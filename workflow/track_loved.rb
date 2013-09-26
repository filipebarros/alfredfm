# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'bundler', 'setup')
require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new(alfred.storage_path, alfred.volatile_storage_path)
  fb = alfred.feedback

  loved_tracks = alfredfm.get_loved_tracks
  loved_tracks.each do |track|
    icon_path = if track['image']
      image = track['image'][1]['content'].split('/')[-1]
      alfredfm.generate_feedback_icon track['image'][1]['content'], :volatile_storage_path, image
    end

    add = if ARGV.empty? || track['artist']['name'].match(/#{ARGV.join(' ')}/i)
      true
    end

    if add
      fb.add_item({
        :uid        => AlfredfmHelper.generate_uuid,
        :title      => track['name'],
        :subtitle   => track['artist']['name'],
        :arg        => track['url'],
        :icon       => icon_path,
        :valid      => 'yes'
      })
    end
  end
  if fb.items.empty?
    fb.add_item({
      :uid        => AlfredfmHelper.generate_uuid,
      :title      => "No artist named #{ARGV.join(' ')} found in the loved tracks!",
      :valid      => 'no'
    })
  end
  puts fb.to_alfred
end
