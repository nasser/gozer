require "simple-rss"
require "open-uri"

# enclosure support hacked in
class SimpleRSS
  @@item_tags << :enclosure
  def clean_content(tag, attrs, content)
    content = content.to_s
    case tag
      when :pubDate, :lastBuildDate, :published, :updated, :expirationDate, :modified, :'dc:date'
        Time.parse(content) rescue unescape(content)
      when :author, :contributor, :skipHours, :skipDays
        unescape(content.gsub(/<.*?>/,''))
      when :enclosure
        attrs[/url="([^"]+)"/, 1]
      else
        content.empty? && "#{attrs} " =~ /href=['"]?([^'"]*)['" ]/mi ? $1.strip : unescape(content)
    end
  end
end

module Gozer
  class Stream
    class Atom < Stream
      def self.new url, extra={}
        feed = SimpleRSS.parse open(url)

        super feed.items.map { |e|
          date = e.updated if e.updated
          date = e.pubDate if e.pubDate

          i = Item.new date

          
          i.author = e.author[/[\s\w]+\n?/].strip if e.author
          i.source = e.link if e.link
          i.content = e.content if e.content
          i.content = e.description if e.description

          case e.enclosure
          when nil
          when /\.(gif|png|jpg|jpeg)$/i
            i.image = e.enclosure
          when /\.(mp3|wav|ogg|aiff|flac)$/i
            i.audio = e.enclosure
          when /\.(mov|mpg|mpeg|m4v|wmv)$/i
            i.video = e.enclosure
          else
            i.enclosure = e.enclosure
          end

          i.host = 'rss'

          i.merge! extra

          i
        }
      end
    end
  end
end