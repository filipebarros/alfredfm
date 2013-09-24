#!/usr/bin/env ruby
# encoding: utf-8

class String
  def trim separator = '[:blank:]'
    trim_re = /[^#{separator}](.*[^#{separator}])?/
    self[trim_re]
  end
end
