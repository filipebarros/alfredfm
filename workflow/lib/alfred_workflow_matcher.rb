#!/usr/bin/env ruby
# encoding: utf-8

module Alfred
 class Feedback
   class Item
     def title_and_subtitle_match? query
       query.empty? || smartcase_query(query).match(@title) || smartcase_query(query).match(@subtitle)
     end
   end
 end
end
