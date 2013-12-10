#!/usr/bin/env ruby
# encoding: utf-8

# Ruby version independent gems
gempath = File.expand_path('gems', File.dirname(__FILE__))
File.directory?(gempath) or raise "Gem path #{gempath} not found."
Dir.glob(File.join(gempath, '*', 'lib')).each { |d| File.directory?(d) and $LOAD_PATH.unshift(d) }
