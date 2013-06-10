require "twitter"
require "json"
require "open-uri"
require "hashie"

require_relative "../gozer/stream"
require_relative "../gozer/item"

module Gozer
  class Stream
    class Twitter < Stream
      class << self
        attr_accessor :credentials
      end

      def self.new handle, tags=[], extra={}
        twitter = ::Twitter::Client.new Twitter.credentials
        twitter.user_timeline(handle, count:100).map do |t|
          next if not tags.empty? and not t.hashtags.any? { |h| tags.include? h.text }

          i = Item.new t.created_at

          i.content = t.text
          i.author = t.user.name
          i.image = t.user.profile_image_url
          i.source = "http://twitter.com/_/status/#{t.id}" # hack
          i.host = 'twitter'

          i.merge! extra

          i
        end.compact
      end
    end
  end
end