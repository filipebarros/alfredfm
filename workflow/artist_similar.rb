# encoding: utf-8

require 'rubygems' unless defined? Gem
require 'alfred'
require File.join(File.dirname(__FILE__), 'bundle', 'bundler', 'setup')
require File.join(File.dirname(__FILE__), 'lib', 'alfredfm_helper')

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new
  AlfredfmHelper.set_paths alfred.storage_path, alfred.volatile_storage_path
  AlfredfmHelper.load_user_information

  fb = alfred.feedback

  begin
    similar = alfredfm.get_similar_artists ARGV

    unless similar.empty?
      similar.each { |artist|
        image = artist['image'][1]['content'].split('/')[-1]
        icon_path = AlfredfmHelper.generate_feedback_icon artist['image'][1]['content'], :volatile_storage_path, image

        rounded = sprintf('%.2f', artist['match']).to_f

        fb.add_item({
          :uid        => AlfredfmHelper.generate_uuid,
          :title      => artist['name'],
          :subtitle   => "#{rounded * 100}% Match",
          :arg        => artist['name'],
          :icon       => icon_path,
          :valid      => 'yes'
        })
      }
    else
      fb.add_item({
        :uid        => AlfredfmHelper.generate_uuid,
        :title      => "No artist named #{ARGV.join(' ')} found!",
        :valid      => 'no'
      })
    end
  rescue Appscript::CommandError
    fb.add_item({
      :uid        => AlfredfmHelper.generate_uuid,
      :title      => "iTunes currently not playing any song!",
      :valid      => 'no'
    })
  end
  puts fb.to_alfred
end
