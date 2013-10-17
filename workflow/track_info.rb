# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'gem_setup.rb')
require 'alfred'
Dir.glob(File.join(File.dirname(__FILE__), 'lib', '*.rb')).each { |f| require f }

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new alfred
  fb = alfred.feedback
  begin
    track_info = alfredfm.get_track_information

    image = track_info.get(['album,', 'image', 1, 'content'])
    icon  = image && AlfredfmHelper.generate_feedback_icon(image, :volatile_storage_path)
    uuid  = AlfredfmHelper.generate_uuid

    fb.add_item(
      :uid        => uuid,
      :title      => track_info['name'],
      :subtitle   => track_info['artist']['name'],
      :arg        => track_info['url'],
      :icon       => icon,
      :valid      => 'yes'
    )
    track_info['userloved'].eql? '1' and
    fb.add_item(
      :uid        => uuid,
      :title      => 'Loved',
      :subtitle   => '',
      :arg        => track_info['url'],
      :icon       => icon,
      :valid      => 'yes'
    )
    fb.add_item(
      :uid        => uuid,
      :title      => "User Playcount: #{LocalizationHelper.format_number(track_info['userplaycount']) || 0}",
      :subtitle   => "Total Playcount: #{LocalizationHelper.format_number(track_info['playcount']) || 0}",
      :arg        => track_info['url'],
      :icon       => icon,
      :valid      => 'yes'
    )
    track_tags = AlfredfmHelper.map_information(track_info['toptags']['tag'], 'name', nil) and
    fb.add_item(
      :uid        => uuid,
      :title      => 'Tags',
      :subtitle   => track_tags,
      :arg        => track_info['url'],
      :icon       => icon,
      :valid      => 'yes'
    )

  rescue OSXMediaPlayer::NoTrackPlayingError => e
    AlfredfmHelper.add_error_item(fb, "#{e.to_s}!", 'Track information lookup only works for the current iTunes track.')

  rescue Lastfm::ApiError => e
    AlfredfmHelper.add_error_item(fb, "No data found for '#{alfredfm.get_track}'.", "#{e.to_s.trim('[:cntrl:][:blank:]')}.")
  end

  puts fb.to_alfred
end
