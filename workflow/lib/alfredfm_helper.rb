# encoding: utf-8

require 'yaml'
require 'appscript'
require 'lastfm'
require 'securerandom'

class AlfredfmHelper
  ACTIONS = {love: 'Loved', add_tags: 'Tagged', ban: 'Banned', remove_tag: 'Untagged'}

  def initialize(storage_path, volatile_storage_path)
    app_info = YAML.load_file('info.yml')
    @api_key = app_info['api_key']
    api_secret = app_info['api_secret']

    @itunes = Appscript.app('iTunes')
    @lastfm = Lastfm.new(@api_key, api_secret)

    @paths = Hash.new
    @paths[:storage_path] = storage_path
    @paths[:volatile_storage_path] = volatile_storage_path

    information = YAML.load_file(File.join(@paths[:storage_path], 'user_info.yml'))
    @token = information['token']
    @username = information['username']
    @session = information['session']
  end

  # Save a hash to file
  # @param path [Symbol] `:storage_path` or `:volatile_storage_path`
  # @param filename [String] name of the file to save
  # @param hash [Hash] hash to save onto file
  def self.save_hash_to_file path, filename, hash
    File.write(File.join(@paths[path], filename), hash.to_yaml)
  end

  # Generate a Universally Uniqued IDentifier
  # @return [String] uuid
  def self.generate_uuid
    return SecureRandom.uuid
  end

  # Convert numbers in format xxxxxxxx to x,xxx,xxx
  # @param number [String] number to split with commas
  # @return [String] comma separated number
  def self.separate_comma number
    number.to_s.chars.to_a.reverse.each_slice(3).map(&:join).join(',').reverse
  end

  def self.map_information information_array, key, failed
    begin
      return information_array.map { |information| information[key].strip }.join(', ')
    rescue Exception
      return failed
    end
  end

  def self.convert_array_to_string array
    if array.kind_of? Array
      array.join(', ')
    else
      array
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
    if information.nil? || information.empty?
      return 'No Information Available!'
    end
    unless information.kind_of? Array
      information = [information]
    end
    times = []
    information.each do |timestamp|
      times << if timestamp['yearto'].empty?
        "#{timestamp['yearfrom']} to Present"
      else
        "#{timestamp['yearfrom']} to #{timestamp['yearto']}"
      end
    end
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

  def generate_feedback_icon(url, path, filename)
    icon = if File.exists?(File.join(@paths[path], filename))
      { :type => 'default', :name => File.join(@paths[path], filename) }
    else
      if url
        img = Net::HTTP.get(URI(url))
        File.write(File.join(@paths[path], filename), img)
        { :type => 'default', :name => File.join(@paths[path], filename) }
      else
        nil
      end
    end
    return icon
  end

  def self.add_event(event, icon, feedback)
    feedback.add_item({
      uid: self.generate_uuid,
      title: "#{event['title']} - #{event['venue']['name']}, #{event['venue']['location']['city']}",
      subtitle: self.convert_array_to_string(event['artists']['artist']),
      arg: "#{event['id']} #{event['title']}",
      icon: icon,
      valid: 'yes'
    })
  end

  def get_token
    return @lastfm.auth.get_token
  end

  def open_in_browser token
    exec("open http://www.last.fm/api/auth/?api_key=#{@api_key}&token=#{token}")
    sleep 15
  end

  def get_session token
    return @lastfm.auth.get_session(token: token)['key']
  end

  def track_action action, arguments
    set_session
    track = @itunes.current_track
    begin
      @lastfm.track.send(action,
        { artist: track.artist.get,
          track:  track.name.get,
          tags:   (arguments if action.eql?(:add_tags)),
          tag:    (arguments.split(',')[0] if action.eql?(:remove_tag))
        }.reject { |key, value| value.nil? }
      )
      return "Successfully #{ACTIONS[action]} #{track.artist.get} by #{track.name.get}"
    rescue Exception
      return 'Unsuccessful!'
    end
  end

  def get_track_information track = nil
    return @lastfm.track.get_info(
      artist:   @itunes.current_track.artist.get,
      track:    @itunes.current_track.name.get,
      username: @username
    )
  end

  def get_album_information album = nil
    return @lastfm.album.get_info(
      artist:   @itunes.current_track.artist.get,
      album:    @itunes.current_track.album.get,
      username: @username
    )
  end

  def get_artist_information artist = nil
    return @lastfm.artist.get_info(
      artist:   get_artist(artist),
      username: @username
    )
  end

  def get_artist_events artist = nil
    return @lastfm.artist.get_events(
      artist: get_artist(artist),
      limit:  10
    )
  end

  def get_similar_artists artist = nil
    _, *tail = @lastfm.artist.get_similar(
      artist: get_artist(artist),
      limit:  10
    )
    return tail
  end

  def get_recommendations recommendation
    set_session
    method = "get_recommended_#{recommendation}".to_sym
    return @lastfm.user.send(method,
      limit: 10
    )
  end

  def get_all_friends
    return @lastfm.user.get_friends(
      user: @username
    )
  end

  def get_loved_tracks
    return @lastfm.user.get_loved_tracks(
      user: @username
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

  def set_session
    @lastfm.session = @session
  end

  def generate_tags action, tags
    return action.eql?(:add_tag) ? tags : tags.split(',')[0]
  end
end
