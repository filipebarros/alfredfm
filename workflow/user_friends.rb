# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'gem_setup.rb')
require 'alfred'
Dir.glob(File.join(File.dirname(__FILE__), 'lib', '*.rb')).each { |f| require f }

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new alfred

  alfred.with_cached_feedback do
    use_cache_file :file => AlfredfmHelper.get_cache_file(File.basename(__FILE__, File.extname(__FILE__))), :expire => 300
  end

  unless fb = alfred.feedback.get_cached_feedback
    fb = alfred.feedback
    begin
      user_friends = alfredfm.get_all_friends
      user_friends.each do |friend|
        name  = AlfredfmHelper.get_friend_name_string friend
        image = friend.get(['image', 1, 'content'])
        icon  = image && AlfredfmHelper.generate_feedback_icon(image, :volatile_storage_path, "#{friend['name']}.png")

        fb.add_item(
          :uid        => AlfredfmHelper.generate_uuid,
          :title      => name,
          :subtitle   => "#{LocalizationHelper.format_number(friend['playcount']) || 0} scrobbles",
          :arg        => friend['name'],
          :icon       => icon,
          :valid      => 'yes'
        )
      end

      unless fb.items.empty?
        fb.put_cached_feedback
        puts fb.to_alfred(ARGV)
        return
      end

      AlfredfmHelper.add_error_item(fb, 'No last.fm friends.')

    rescue Lastfm::ApiError => e
      AlfredfmHelper.add_error_item(fb, "No data found for '#{ARGV.join(' ')}'.", "#{e.to_s.trim('[:cntrl:][:blank:]')}.")
    end
  end

  puts fb.to_alfred
end
