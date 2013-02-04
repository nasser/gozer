require "json"
require "hashie"
require "open-uri"

module Gozer
  class Stream
    class Tumblr < Stream
      class << self
        attr_accessor :api_key
      end

      def self.new blog_url
        api_url = "http://api.tumblr.com/v2/blog/#{blog_url}/posts?api_key=#{Tumblr.api_key}"
        JSON.parse(open(api_url).read)['response']['posts'].map { |p|
          p = Hashie::Mash.new(p)
          i = Item.new Time.parse(p.date)

          # i.image = p.author.avatar_url
          # i.author = p.commit.author.name
          i.source = p.post_url
          i.content = p.caption
          i.host = "tumblr"

          i
        }
      end
    end
  end
end