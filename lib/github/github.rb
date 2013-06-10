require "json"
require "hashie"
require "open-uri"

module Gozer
  class Stream
    class Github < Stream
      class << self
        attr_accessor :credentials
      end

      def self.new user, project, branch="master", extra={}
        api_url = "https://api.github.com/repos/#{user}/#{project}/commits?client_id=#{Github.credentials[:client_id]}&client_secret=#{Github.credentials[:client_secret]}"
        JSON.parse(open(api_url).read).map {|c|
          c = Hashie::Mash.new(c)
          i = Item.new Time.parse(c.commit.author.date)

          i.image = c.author.avatar_url
          i.author = c.commit.author.name
          i.source = "https://github.com/#{user}/#{project}/commit/#{c.sha}"
          i.content = c.commit.message
          i.host = "github"

          i.merge! extra

          i
        }
      end
    end
  end
end