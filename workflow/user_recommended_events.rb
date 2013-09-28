# encoding: utf-8

require 'rubygems' unless defined? Gem
require File.join(File.dirname(__FILE__), 'bundle', 'gem_setup.rb')
require 'alfred'
Dir.glob(File.join(File.dirname(__FILE__), 'lib', '*.rb')).each { |f| require f }

Alfred.with_friendly_error do |alfred|
  alfredfm = AlfredfmHelper.new alfred

  alfred.with_cached_feedback do
    use_cache_file :file => AlfredfmHelper.get_cache_file(File.basename(__FILE__, File.extname(__FILE__))), :expire => 900
  end

  unless fb = alfred.feedback.get_cached_feedback
    fb = alfred.feedback
    begin
      recommended_events = alfredfm.get_recommended_events
      recommended_events.each do |event|
        image = event.get(['image', 1, 'content'])
        icon  = image && AlfredfmHelper.generate_feedback_icon(image, :volatile_storage_path);

        fb.add_item({
          :uid        => AlfredfmHelper.generate_uuid,
          :title      => "#{event['title']} – #{event['venue']['name']}, #{event['venue']['location']['city']}",
          :subtitle   => "#{LocalizationHelper.format_date(event['startDate'])} – #{Array(event['artists']['artist']).join(', ')}",
          :arg        => "#{event['id']} #{event['title']}",
          :icon       => icon,
          :valid      => 'yes'
        })
      end

      unless fb.items.empty?
        fb.put_cached_feedback
        puts fb.to_alfred(ARGV)
        return
      end

      AlfredfmHelper.add_error_item(fb, 'No recommended events.')

    rescue Lastfm::ApiError => e
      AlfredfmHelper.add_error_item(fb, "No data found for '#{ARGV.join(' ')}'.", "#{e.to_s.trim('[:cntrl:][:blank:]')}.")
    end
  end

  puts fb.to_alfred
end
