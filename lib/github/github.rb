require "json"
require "hashie"
require "open-uri"

module Gozer
  class Stream
    class Github < Stream
      def self.new user, project, branch="master"
        JSON.parse(open("https://api.github.com/repos/#{user}/#{project}/commits").read).map {|c|
          c = Hashie::Mash.new(c)
          i = Item.new Time.parse(c.commit.author.date)

          i.image = c.author.avatar_url
          i.author = c.commit.author.name
          i.source = "https://github.com/#{user}/#{project}/commit/#{c.sha}"
          i.content = c.commit.message
          i.host = "github"

          i
        }
      end
    end
  end
end