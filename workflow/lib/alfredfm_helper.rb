#!/usr/bin/env ruby
# encoding: utf-8

require 'yaml'
require 'appscript'
require 'lastfm'
require 'securerandom'

class AlfredfmHelper
  def initialize
    app_info = YAML.load_file("info.yml")
    @api_key = app_info['api_key']
    api_secret = app_info['api_secret']

    @itunes = Appscript.app('iTunes')
    @lastfm = Lastfm.new(@api_key, api_secret)
  end

  def self.set_paths storage_path, volatile_storage_path
    @paths = Hash.new
    @paths[:storage_path] = storage_path
    @paths[:volatile_storage_path] = volatile_storage_path
  end

  def self.load_user_information
    information = YAML.load_file(File.join(@paths[:storage_path], 'user_info.yml'))
    @token = information['token']
    @@username = information['username']
    @@session = information['session']
  end

  def self.save_hash_to_file path, filename, hash
    File.write(File.join(@paths[path], filename), hash.to_yaml)
  end

  def self.generate_uuid
    return SecureRandom.uuid
  end

  def self.separate_comma number
    number.to_s.chars.to_a.reverse.each_slice(3).map(&:join).join(",").reverse
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

  def self.get_list array
    if array.kind_of? Array
      array.join ', '
    else
      array
    end
  end

  def self.get_timestamp_string information
    if !information.kind_of? Array
      information = [information]
    end
    times = []
    information.each { |timestamp|
      times << if timestamp['yearto'].empty?
        "#{timestamp['yearfrom']} to Present"
      else
        "#{timestamp['yearfrom']} to #{timestamp['yearto']}"
      end
    }
    return times.join ', '
  end

  def self.get_friend_name_string friend_info
    string_name = if friend_info['realname'].empty?
      friend_info['name']
    else
      "#{friend_info['realname']} - #{friend_info['name']}"
    end
    return string_name
  end

  def self.generate_feedback_icon url, path, filename
    icon = unless File.exists?(File.join(@paths[path], filename))
      if url
        img = Net::HTTP.get(URI(url))
        File.write(File.join(@paths[path], filename), img)
        { :type => 'default', :name => File.join(@paths[path], filename) }
      else
        nil
      end
    else
      { :type => "default", :name => File.join(@paths[path], filename) }
    end

    return icon
  end

  def get_token
    return @lastfm.auth.get_token
  end

  def open_in_browser token
    `open "http://www.last.fm/api/auth/?api_key=#{@api_key}&token=#{token}"`
    sleep 15
  end

  def get_session token
    return @lastfm.auth.get_session(:token => token)['key']
  end

  def love_track
    @lastfm.session = @@session
    begin
      @lastfm.track.love(
        :artist => @itunes.current_track.artist.get,
        :track => @itunes.current_track.name.get
      )
      return "Successfully Loved #{@itunes.current_track.artist.get} by #{@itunes.current_track.name.get}"
    rescue Exception => e
      return "Unsuccessful!"
    end
  end

  def get_track_information track = nil
    return @lastfm.track.get_info(
      :artist => @itunes.current_track.artist.get,
      :track => @itunes.current_track.name.get,
      :username => @@username
    )
  end

  def get_album_information album = nil
    return @lastfm.album.get_info(
      :artist => @itunes.current_track.artist.get,
      :album => @itunes.current_track.album.get,
      :username => @@username
    )
  end

  def get_artist_information artist = nil
    return @lastfm.artist.get_info(
      :artist => get_artist(artist),
      :username => @@username
    )
  end

  def get_artist_events artist = nil
    return @lastfm.artist.get_events(
      :artist => get_artist(artist),
      :limit => 10
    )
  end

  def get_similar_artists artist = nil
    head, *tail = @lastfm.artist.get_similar(
      :artist => get_artist(artist),
      :limit => 10
    )
    return tail
  end

  def get_all_friends
    return @lastfm.user.get_friends(
      :user => @@username
    )
  end

  def get_loved_tracks
    return @lastfm.user.get_loved_tracks(
      :user => @@username,
    )
  end

  private
    def get_artist artist
      if artist.empty?
        @itunes.current_track.artist.get
      else
        artist.join(' ')
      end
    end
end
