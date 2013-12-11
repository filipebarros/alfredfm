# encoding: utf-8

require 'yaml'
require 'lastfm'
require 'securerandom'
require 'uri'
require 'net/http'

class AlfredfmHelper
  ACTIONS = { love: 'Loved', add_tags: 'Tagged', ban: 'Banned', remove_tag: 'Untagged' }

  def initialize(alfred)
    app_info   = YAML.load_file('info.yml')
    @api_key   = app_info[:api_key]
    api_secret = app_info[:api_secret]

    @lastfm = Lastfm.new(@api_key, api_secret)

    @@paths = {
      storage_path:          alfred.storage_path,
      volatile_storage_path: alfred.volatile_storage_path
    }

    user_info_file = File.join(@@paths[:storage_path], 'user_info.yml')
    if File.exist?(user_info_file)
      user_info  = YAML.load_file(user_info_file)
      @token     = user_info[:token]    || user_info['token']
      @@username = user_info[:username] || user_info['username']
      @@session  = user_info[:session]  || user_info['session']
    end
  end

  # Save a hash to file
  # @param path [Symbol] `:storage_path` or `:volatile_storage_path`
  # @param filename [String] name of the file to save
  # @param hash [Hash] hash to save onto file
  def self.save_hash_to_file(path, filename, hash)
    File.open(File.join(@@paths[path], filename), 'w') do |f|
      f.write hash.to_yaml
    end
  end

  # Generate a Universally Uniqued Identifier
  # @return [String] uuid
  def self.generate_uuid
    SecureRandom.uuid
  end

  # Maps information into an array of values
  # @param information_array [Array] array of hashes to map into an Array
  # @param key [String] name of the key to map into Array. Used to get the values from the Hash
  # @param failed [String] String message to be returned if it is not possible to map the information
  # @return [Array] with all the mapped information
  def self.map_information(information_array, key, failed)
    begin
      return information_array.map { |information| information[key].strip }.join(', ')
    rescue Exception
      return failed
    end
  end

  # Generate a Timestamp String from an Array of Hashes
  # @param information [Array] array of hashes to extract the date
  # @return [String] with a formatted date
  def self.get_timestamp_string(information)
    information = [information] unless information.kind_of? Array

    times = information.map { |timestamp|
      if timestamp['yearto'].empty?
        "#{timestamp['yearfrom']} to Present"
      else
        "#{timestamp['yearfrom']} to #{timestamp['yearto']}"
      end
    }.join ', '
  end

  # Generate a String with the friend name and username
  # @param friend_info [Array] Array with the last.fm friend information
  # @return [String] formatted name with realname when available and username
  def self.get_friend_name_string(friend_info)
    string_name = if friend_info['realname'].empty?
      friend_info['name']
    else
      "#{friend_info['realname']} – #{friend_info['name']}"
    end
  end

  # Generate a feedback icon to be passed to alfred
  # @param url [String] url of the image to use as the icon
  # @param path [Symbol] path where to store the image
  # @param filename [String] filename to save image, if needed. When not passed it will be nil
  # @return [Hash] icon information to be passed to alfred. Formatted according with the alfred gem
  def self.generate_feedback_icon(url, path, filename = nil)
    filename ||= URI.split(url)[5].split('/').last
    filepath   = File.join(@@paths[path], filename)
    unless File.exists?(filepath)
      url and File.open(filepath, 'w') do |f|
        f.write Net::HTTP.get(URI(url))
      end
    end
    { :type => 'default', :name => filepath }
  end

  # Add a error item to be presented in alfred
  # @param feedback [Alfred::Feedback] feedback item to be presented
  # @param title [String] title of the feedback item
  # @param subtitle [String] subtitle to of the feedback item
  # @return [Alfred::Feedback] feedback item
  def self.add_error_item(feedback, title, subtitle = nil)
    feedback.add_item({
      uid: AlfredfmHelper.generate_uuid,
      title: title,
      subtitle: subtitle,
      valid: 'no'
    })
  end

  # Get cached feedback
  # @param name [String] name of the cached feedback
  # @return [File] file with the generated feedback
  def self.get_cache_file(name = 'cached')
    File.join(@@paths[:volatile_storage_path], "#{name}_feedback")
  end

  # Check if iTunes is running
  # @return [boolean]
  def itunes_running?
    %x{osascript -e 'get running of application id "com.apple.itunes"'}.chomp == 'true'
  end

  # Get currently playing iTunes track information
  # @param trackinfo [String] information wanted (artist, track name, album)
  # @return information about the track
  def get_itunes_trackinfo(trackinfo)
    itunes_running? or raise OSXMediaPlayer::NoTrackPlayingError, 'iTunes is not running'
    itunes_command = [
      'tell application id "com.apple.itunes"',
      'try',
      "get #{trackinfo.to_s} of current track",
      'end try',
      'end tell'
    ]
     %x{osascript -e '#{itunes_command.join("' -e '")}'}.chomp.trim or
       raise OSXMediaPlayer::NoTrackPlayingError, 'No track playing in iTunes'
  end

  # Gets artist name, depending if it was passed or not. If not passed, it will be fetched from iTunes
  # @param artist [Array] artist, each name is a position of the array (ARGV)
  # @return [String] artist name
  def get_artist(artist = nil)
    Array(artist).join(' ').trim || get_itunes_trackinfo(:artist)
  end

  # Fetches currently playing track
  # @return currently playing track name
  def get_track
    get_itunes_trackinfo(:name)
  end

  # Fetches album of the currently playing track
  # @return album of the currently playing track
  def get_album
    get_itunes_trackinfo(:album)
  end

  # Get Last.fm Authentication Token
  def get_token
    @lastfm.auth.get_token
  end

  # Open the authentication page in a browser
  # @param token [String] Last.fm Authentication Token
  def open_in_browser(token)
    %x{open "http://www.last.fm/api/auth/?api_key=#{@api_key}&token=#{token}"}
    sleep 15
  end

  # Get Last.fm Session
  # @param token [String] Last.fm Authentication Token
  def get_session(token)
    @lastfm.auth.get_session(:token => token)['key']
  end

  # Execute a action on a track
  # The supported actions are: love, ban, add_tags and remove_tag
  # @param action [Symbol] action to execute
  # @param arguments [String] arguments to pass to the action (add_tags and remove_tag)
  def track_action(action, arguments)
    track  = get_itunes_trackinfo(:name)
    artist = get_itunes_trackinfo(:artist)
    begin
      @lastfm.session = @@session
      @lastfm.track.send(action,
        {
          artist: artist,
          track: track,
          tags: (arguments if action.eql?(:add_tags)),
          tag: (arguments.split(',')[0] if action.eql?(:remove_tag))
        }.reject { |_, value| value.nil? }
      )
      "Successfully #{ACTIONS[action]} #{track} by #{artist}"
    rescue Exception => e
      "Could not #{action.titleize('_')} #{track}: #{e.to_s}."
    end
  end

  def get_charts(type)
    charts = @lastfm.library.send(type,
      user: @@username,
      limit: 10
    )
  end

  def get_track_information
    artist = get_itunes_trackinfo(:artist)
    track  = get_itunes_trackinfo(:name)
    @lastfm.track.get_info(
      artist: artist,
      track: track,
      username: @@username
    )
  end

  def get_album_information
    artist = get_itunes_trackinfo(:artist)
    album  = get_itunes_trackinfo(:album)
    @lastfm.album.get_info(
      artist: artist,
      album: album,
      username: @@username
    )
  end

  def get_artist_information(artist = nil)
    artist = get_artist(artist)
    @lastfm.artist.get_info(
      artist: artist,
      username: @@username
    )
  end

  def get_artist_events(artist = nil)
    artist = get_artist(artist)
    @lastfm.artist.get_events(
      artist: artist,
      limit: 10
    )
  end

  def get_similar_artists(artist = nil)
    artist = get_artist(artist)
    @lastfm.artist.get_similar(
      artist: artist,
      limit: 10
    )[1..-1]
  end

  def get_recommended_artists
    @lastfm.session = @@session
    @lastfm.user.get_recommended_artists(:limit => 10)
  end

  def get_recommended_events
    @lastfm.session = @@session
    @lastfm.user.get_recommended_events(:limit => 10)
  end

  def get_all_friends
    @lastfm.user.get_friends(:user => @@username)
  end

  def get_loved_tracks
    @lastfm.user.get_loved_tracks(:user => @@username)
  end

  private :get_itunes_trackinfo
end
