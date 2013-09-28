#!/usr/bin/env ruby
# encoding: utf-8

# Ruby version independent gems
gempath = File.expand_path('gems', File.dirname(__FILE__))
File.directory?(gempath) or raise "Gem path #{gempath} not found."
Dir.glob(File.join(gempath, '*', 'lib')).each { |d| File.directory?(d) and $LOAD_PATH.unshift(d) }

# Ruby version dependend gems (must be located under version number folder)
gempath_versioned = File.expand_path('gems-versioned', File.dirname(__FILE__))
if File.directory?(gempath_versioned)
  Dir.glob(File.join(gempath_versioned, '*')).each do |version_dir|
    if RUBY_VERSION.to_f >= version_dir.split(File::SEPARATOR).last.to_f
      Dir.glob(File.join(version_dir, '*', 'lib')).each { |d| File.directory?(d) and $LOAD_PATH.unshift(d) }
    end
  end
end
