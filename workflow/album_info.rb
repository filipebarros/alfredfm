# encoding: utf-8

require File.join(File.dirname(__FILE__), 'bundle', 'bundler', 'setup.rb')
require 'alfred'
Dir.glob(File.join(File.dirname(__FILE__), 'lib', '*.rb')).each { |f| require f }

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new alfred
  fb = alfred.feedback
  begin
    album_info = alfredfm.get_album_information
    image = album_info.get(['image', 1, 'content'])
    icon  = image && AlfredfmHelper.generate_feedback_icon(image, :volatile_storage_path)
    uuid  = AlfredfmHelper.generate_uuid

    fb.add_item(
      uid: uuid,
      title: album_info['name'],
      subtitle: album_info['artist'],
      arg: album_info['url'],
      icon: icon,
      valid: 'yes'
    )
    album_info['releasedate'].empty? or fb.add_item(
      uid: uuid,
      title: 'Release Date',
      subtitle: LocalizationHelper.format_date(album_info['releasedate'], :full),
      arg: album_info['url'],
      icon: icon,
      valid: 'yes'
    )
    fb.add_item(
      uid: uuid,
      title: "User Playcount: #{LocalizationHelper.format_number(album_info['userplaycount']) || 0}",
      subtitle: "Total Playcount: #{LocalizationHelper.format_number(album_info['playcount']) || 0}",
      arg: album_info['url'],
      icon: icon,
      valid: 'yes'
    )
    album_info.get(['toptags', 'tag']).empty? or fb.add_item(
      uid: uuid,
      title: 'Tags',
      subtitle: AlfredfmHelper.map_information(album_info['toptags']['tag'], 'name', nil),
      arg: album_info['url'],
      icon: icon,
      valid: 'yes'
    )

  rescue OSXMediaPlayer::NoTrackPlayingError => e
    AlfredfmHelper.add_error_item(fb, "#{e.to_s}!", 'Album information lookup only works for the current iTunes track.')

  rescue Lastfm::ApiError => e
    AlfredfmHelper.add_error_item(fb, "No data found for '#{alfredfm.get_album}'.", "#{e.to_s.trim('[:cntrl:][:blank:]')}.")
  end

  puts fb.to_alfred
end
