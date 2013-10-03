# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'gem_setup.rb')
require 'alfred'
Dir.glob(File.join(File.dirname(__FILE__), 'lib', '*.rb')).each { |f| require f }

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new alfred
  fb = alfred.feedback
  action = ARGV[0].to_sym

  user_option_charts = alfredfm.get_charts action
  user_option_charts.each do |option|
    image = option.get(['image', 1, 'content'])
    icon  = image && AlfredfmHelper.generate_feedback_icon(image, :volatile_storage_path)
    uuid  = option['mbid'].empty? ? AlfredfmHelper.generate_uuid : option['mbid']

    fb.add_item(
      :uid => uuid,
      :title => option['name'],
      :subtitle => "#{option['playcount']} scrobbles",
      :arg => option['url'],
      :icon => icon,
      :valid => 'yes'
    )
  end
  puts fb.to_alfred
end
