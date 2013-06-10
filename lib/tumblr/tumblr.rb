require "json"
require "hashie"
require "open-uri"

module Gozer
  class Stream
    class Tumblr < Stream
      class << self
        attr_accessor :api_key
      end

      def self.new blog_url, extra={}
        api_url = "http://api.tumblr.com/v2/blog/#{blog_url}/posts?api_key=#{Tumblr.api_key}"
        JSON.parse(open(api_url).read)['response']['posts'].map { |p|
          p = Hashie::Mash.new(p)
          i = Item.new Time.parse(p.date)

          i.source = p.post_url
          i.host = "tumblr"
          i.type = p.type

          case i.type
          when 'text'
            i.title = p.title
            i.content = p.body
          when 'photo'
            i.content = p.caption
            i.image = p.photos[0].original_size.url
            # alt sizes?
          when 'quote'
            i.content = p.text
            i.quote_source = p.source
          when 'link'
            i.content = p.description
            i.title = p.title
            i.url = p.url
          when 'chat'
            i.title = p.title
            i.content = p.body
          when 'audio'
            i.content = p.caption
            i.player = p.player
          when 'video'
            i.content = p.caption
            i.player = p.player.last.embed_code
            # alt sizes?
          end

          i.merge! extra

          i
        }
      end
    end
  end
end