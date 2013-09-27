#!/usr/bin/env ruby
# encoding: utf-8

class String
  # `strip` any regex character class, return nil if the resulting String is empty.
  def trim separator = '[:blank:]'
    trim_re = /[^#{separator}](.*[^#{separator}])?/
    self[trim_re]
  end
end

class Hash
  # Return a value from a nested Hash / Array structure by passing it an array of keys.
  # Returns nil if a key anywhere in the chain is not found.
  # Based on http://stackoverflow.com/questions/8479476/iterating-through-a-ruby-nested-hash-with-nils
  def get keys, default = nil
    Array(keys).reduce(self) do |memo, key|
      memo[key] if memo.is_a?(Hash) || (memo.is_a?(Array) && key.is_a?(Integer))
    end or default
  end
end

class NilClass
  # Allow tests like foo[bar].empty? for a non existent key 'bar'.
  def empty?; true; end
end

class Float
  if RUBY_VERSION.to_f < 1.9
    # Emulate `round` behaviour of Ruby 1.9 and above.
    # Based on http://code.goingasplannedby.us/2013/06/05/ruby-rounding-floats/
    def precision(p)
      p = p.to_i if p.is_a?(Float)
      p <  0 and return (self / 10 ** p.abs).round * 10 ** p.abs
      p == 0 ? self.round : (self * 10 ** p).round.to_f / 10 ** p
    end
  else
    def precision(p); round(p); end
  end
end

class Symbol
  # Titleize Symbol And Return as a Space Splitted String
  # @param split [String] char to split the symbol
  def titleize split
    self.to_s.split(split).map(&:capitalize).join(' ')
  end
end
