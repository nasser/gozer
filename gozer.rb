require "open-uri"

require "sinatra"
require "hashie"
require "json"

require_relative "lib/gozer/stream"
require_relative "lib/gozer/item"

require_relative "lib/atom/atom"
require_relative "lib/github/github"
require_relative "lib/tumblr/tumblr"
require_relative "lib/twitter/twitter"

def demo_stream
  Gozer::Stream::Tumblr.api_key = ENV['TUMBLR_API_KEY']
  Gozer::Stream::Twitter.credentials = {
    :consumer_key => ENV["TWITTER_CONSUMER_KEY"],
    :consumer_secret => ENV["TWITTER_CONSUMER_SECRET"],
    :oauth_token => ENV["TWITTER_OAUTH_TOKEN"],
    :oauth_token_secret => ENV["TWITTER_OAUTH_TOKEN_SECRET"]
  }
  Gozer::Stream::Github.credentials = {
    :client_id => ENV["GITHUB_CLIENT_ID"],
    :client_secret => ENV["GITHUB_CLIENT_SECRET"]
  }

  stream = Gozer::Stream.new []
  
  toby = { artist:"Toby Schachman", project:"Pixel Shaders" }
  stream += Gozer::Stream::Github.new "electronicwhisper", "pixel-shaders", "master", toby
  stream += Gozer::Stream::Github.new "electronicwhisper", "arthackday-refractor", "master", toby
  stream += Gozer::Stream::Atom.new "http://journal.pixelshaders.com/rss", toby

  forrest = { artist:"Forrest Oliphant", project:"Meemoo" }
  stream += Gozer::Stream::Atom.new "http://feeds.feedburner.com/meemoo?format=xml", forrest
  stream += Gozer::Stream::Github.new "meemoo", "iframework", "master", forrest
  stream += Gozer::Stream::Github.new "meemoo", "dataflow", "master", forrest
  stream += Gozer::Stream::Twitter.new "forresto", ["meemoo"], forrest
  stream += Gozer::Stream::Tumblr.new "meemooapp.tumblr.com", forrest

  nortd = { artist:"Nortd Labs", project:"Bomfu" }
  stream += Gozer::Stream::Twitter.new "lasersaur", [], nortd
  stream += Gozer::Stream::Github.new "nortd", "bomfu", "master", nortd

  stream
end

before do
  headers["Access-Control-Allow-Origin"] = "*"
  headers["Access-Control-Allow-Methods"] = "*"
end

get "/" do
  erb :index
end

get "/demo.json" do
  content_type 'application/json'
  
  demo_stream.to_json
end

get "/demo.html" do
  content_type 'text/html'

  demo_stream.map do |item|
    "<div class='stream-item' id='item-#{item.object_id}'>" +
    item.keys.map do |key| 
      "<span class='#{key}'>#{item[key]}</span>"
    end.join("\n") +
    "</div>"
  end.join("\n")
end
