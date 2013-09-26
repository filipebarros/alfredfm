# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'bundler', 'setup')
require 'alfred'
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new(alfred.storage_path, alfred.volatile_storage_path)
  fb = alfred.feedback

  recommended_artists = alfredfm.get_recommendations :artists
  recommended_artists.each do |recommendation|
    image = recommendation['image'][1]['content'].split('/')[-1]
    icon_path = alfredfm.generate_feedback_icon recommendation['image'][1]['content'], :volatile_storage_path, image

    similar = AlfredfmHelper.map_information recommendation['context']['artist'], 'name', 'No Similar Artists!'

    fb.add_item({
      uid:      AlfredfmHelper.generate_uuid,
      title:    recommendation['name'],
      subtitle: similar,
      arg:      recommendation['name'],
      icon:     icon_path,
      valid:    'yes'
    })
  end
  puts fb.to_alfred
end
