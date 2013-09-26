#!/usr/bin/env ruby
# encoding: utf-8

require 'yaml'
require 'lastfm'
require 'securerandom'
require 'net/http'

class AlfredfmHelper
  def initialize alfred
    app_info   = YAML.load_file('info.yml')
    @api_key   = app_info[:api_key]
    api_secret = app_info[:api_secret]

    @lastfm = Lastfm.new(@api_key, api_secret)

    @@paths = {
      :storage_path          => alfred.storage_path,
      :volatile_storage_path => alfred.volatile_storage_path
    }

    user_info_file = File.join(@@paths[:storage_path], 'user_info.yml')
    if File.exist?(user_info_file)
      user_info  = YAML.load_file(user_info_file)
      @token     = user_info[:token]
      @@username = user_info[:username]
      @@session  = user_info[:session]
    end
  end

  # Save a hash to file
  # @param path [Symbol] `:storage_path` or `:volatile_storage_path`
  # @param filename [String] name of the file to save
  # @param hash [Hash] hash to save onto file
  def self.save_hash_to_file path, filename, hash
    File.write(File.join(@@paths[path], filename), hash.to_yaml)
  end

  # Generate a Universally Uniqued Identifier
  # @return [String] uuid
  def self.generate_uuid
    SecureRandom.uuid
  rescue NoMethodError # SecureRandom.uuid is Ruby >= 1.9
    require 'uuidtools'
    UUIDTools::UUID.random_create.to_s
  end

  def self.map_information information_array, key, failed
    begin
      return information_array.map { |information|
        information[key].strip
      }.join(', ')
    rescue Exception => e
      return failed
    end
  end

  def self.get_timestamp_string information
    if information['yearto'].empty?
      "#{information['yearfrom']} to Present"
    else
      "#{information['yearfrom']} to #{information['yearto']}"
    end
  end

  def self.get_friend_name_string friend_info
    string_name = if friend_info['realname'].empty?
      friend_info['name']
    else
      "#{friend_info['realname']} – #{friend_info['name']}"
    end
    return string_name
  end

  def self.generate_feedback_icon url, path, filename
    filepath = File.join(@@paths[path], filename)
    unless File.exists?(filepath)
      url and File.open(filepath, 'w') do |f|
        f.write Net::HTTP.get(URI(url))
      end
    end
    { :type => 'default', :name => filepath }
  end

  def self.add_error_item feedback, title, subtitle = nil
    feedback.add_item({
      :uid        => AlfredfmHelper.generate_uuid,
      :title      => title,
      :subtitle   => subtitle,
      :valid      => 'no'
    })
  end

  def itunes_running?
    %x{osascript -e 'get running of application id "com.apple.itunes"'}.chomp == 'true'
  end

  def get_itunes_trackinfo trackinfo
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

  def get_artist artist
    Array(artist).join(' ').trim || get_itunes_trackinfo(:artist)
  end

  def get_token
    @lastfm.auth.get_token
  end

  def open_in_browser token
    %x{open "http://www.last.fm/api/auth/?api_key=#{@api_key}&token=#{token}"}
    sleep 15
  end

  def get_session token
    @lastfm.auth.get_session(:token => token)['key']
  end

  def love_track
    artist = get_itunes_trackinfo(:artist)
    track  = get_itunes_trackinfo(:name)
    begin
      @lastfm.session = @@session
      @lastfm.track.love(:artist => artist, :track => track)
      "Successfully Loved #{track} by #{artist}."
    rescue Exception => e
      return "Unsuccessful!"
    end
  end

  def ban_track
    artist = get_itunes_trackinfo(:artist)
    track  = get_itunes_trackinfo(:name)
    begin
      @lastfm.session = @@session
      @lastfm.track.ban(:artist => artist, :track => track)
      "Successfully Banned #{track} by #{artist}."
    rescue Exception => e
      return "Unsuccessful"
    end
  end

  def tag_track tags
    artist = get_itunes_trackinfo(:artist)
    track  = get_itunes_trackinfo(:name)
    tags   = tags.join(' ').trim and begin
      @lastfm.session = @@session
      @lastfm.track.add_tags(:artist => artist, :track => track, :tags => tags)
      "Successfully Tagged #{track} by #{artist} with tags #{tags}."
    rescue Exception => e
      return "Unsuccessful"
    end
  end

  def untag_track tag
    artist = get_itunes_trackinfo(:artist)
    track  = get_itunes_trackinfo(:name)
    tag    = tag.join(' ').split(',').first.trim and begin
      @lastfm.session = @@session
      @lastfm.track.remove_tag(:artist => artist, :track => track, :tags => tag)
      "Successfully removed Tag #{tag} from #{track} by #{artist}."
    rescue Exception => e
      return "Unsuccessful"
    end
  end

  def get_track_information
    artist = get_itunes_trackinfo(:artist)
    track  = get_itunes_trackinfo(:name)
    @lastfm.track.get_info(
      :artist   => artist,
      :track    => track,
      :username => @@username
    )
  end

  def get_album_information
    artist = get_itunes_trackinfo(:artist)
    album  = get_itunes_trackinfo(:album)
    @lastfm.album.get_info(
      :artist   => artist,
      :album    => album,
      :username => @@username
    )
  end

  def get_artist_information artist = nil
    artist = get_artist(artist)
    artist_info = @lastfm.artist.get_info(
      :artist   => artist,
      :username => @@username
    )
  end

  def get_artist_events artist = nil
    artist = get_artist(artist)
    @lastfm.artist.get_events(
      :artist => artist,
      :limit  => 10
    )
  end

  def get_similar_artists artist = nil
    artist = get_artist(artist)
    @lastfm.artist.get_similar(
      :artist => artist,
      :limit  => 10
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

  private :get_artist, :get_itunes_trackinfo
end
