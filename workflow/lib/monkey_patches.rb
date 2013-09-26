#!/usr/bin/env ruby
# encoding: utf-8

class String
  def trim separator = '[:blank:]'
    trim_re = /[^#{separator}](.*[^#{separator}])?/
    self[trim_re]
  end
end

# Based on http://stackoverflow.com/questions/8479476/iterating-through-a-ruby-nested-hash-with-nils
class Hash
  def get(keys, default = nil)
    Array(keys).reduce(self) do |memo, key|
      memo[key] if memo.is_a?(Hash) || (memo.is_a?(Array) && key.is_a?(Integer))
    end or default
  end
end

