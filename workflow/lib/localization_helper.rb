#!/usr/bin/env ruby
# encoding: utf-8

require 'r18n-desktop'

R18n.from_env(File.expand_path('../i18n', __FILE__), %x{defaults read .GlobalPreferences AppleLocale}.chomp)
include R18n::Helpers

class LocalizationHelper
  def self.format_number number
    if number.is_a?(String)
      number = Integer(number) rescue Float(number)
    end
    l number
  end

  def self.format_date datetime, format = nil
    l(Date.parse(datetime), format).trim
  end
end

