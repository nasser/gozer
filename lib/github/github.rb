require "octokit"

module Gozer
  class Stream
    class Github < Stream
      def self.new user, project, branch="master"
        super Octokit.commits("#{user}/#{project}", branch).map {|c|
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