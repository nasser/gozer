require "simple-rss"
require "open-uri"

module Gozer
  class Stream
    class Atom < Stream
      def self.new url
        feed = SimpleRSS.parse open(url)

        super feed.items.map { |e|
          date = e.updated if e.updated
          date = e.pubDate if e.pubDate

          i = Item.new date
          
          i.author = e.author[/[\s\w]+\n/].strip if e.author
          i.source = e.link if e.link
          i.content = e.content if e.content
          i.content = e.description if e.description
          i.host = url

          i
        }
      end
    end
  end
end