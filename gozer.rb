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

before do
  headers["Access-Control-Allow-Origin"] = "*"
  headers["Access-Control-Allow-Methods"] = "*"

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
end

class Gozer::Stream
  def add_artist name
    stream = self

    case name
    when :toby
      toby = { artist:"Toby Schachman", project:"Pixel Shaders" }
      stream += Gozer::Stream::Github.new "electronicwhisper", "pixel-shaders", "master", toby
      stream += Gozer::Stream::Github.new "electronicwhisper", "arthackday-refractor", "master", toby
      stream += Gozer::Stream::Atom.new "http://journal.pixelshaders.com/rss", toby
    when :forrest
      forrest = { artist:"Forrest Oliphant", project:"Meemoo" }
      stream += Gozer::Stream::Atom.new "http://feeds.feedburner.com/meemoo?format=xml", forrest
      stream += Gozer::Stream::Github.new "meemoo", "iframework", "master", forrest
      stream += Gozer::Stream::Github.new "meemoo", "dataflow", "master", forrest
      stream += Gozer::Stream::Twitter.new "forresto", ["meemoo"], forrest
      stream += Gozer::Stream::Tumblr.new "meemooapp.tumblr.com", forrest
    when :nortd
      nortd = { artist:"Nortd Labs", project:"Bomfu" }
      stream += Gozer::Stream::Twitter.new "lasersaur", [], nortd
      stream += Gozer::Stream::Github.new "nortd", "bomfu", "master", nortd
    end

    stream
  end
end

def demo_stream!
  stream = Gozer::Stream.new []

  stream = stream.add_artist :toby
  stream = stream.add_artist :forrest
  stream = stream.add_artist :nortd

  stream
end

get "/" do
  erb :index
end

def demo_stream options={}

  
  if @@last_update.nil? or (Time.now - @@last_update > options["cache_time"].to_i)
    @@cached_stream = demo_stream!
    @@last_update = Time.now
  end

  if options["page"]
    page = options["page"].to_i
    ipp = options["items_per_page"].to_i
    @@cached_stream[(page*ipp)...(page*ipp+ipp)]

  else
    @@cached_stream

  end
end

get "/*.json" do |name|
  content_type 'application/json'

  params["cache_time"] ||= 3600
  params["page"] ||= 0
  params["items_per_page"] ||= nil

  name = 'all' if name == 'demo'
  name = name.to_sym

  # caching
  @@last_update ||= nil
  @@cached_streams ||= {}

  if @@cached_streams[name].nil? or @@last_update.nil? or (Time.now - @@last_update > params["cache_time"].to_i)
    # cache miss or expired, update stream
    stream = Gozer::Stream.new []

    if name == :all
      stream = stream.add_artist :toby
      stream = stream.add_artist :forrest
      stream = stream.add_artist :nortd
    else
      stream = stream.add_artist name
    end

    @@cached_streams[name] = stream
    @@last_update = Time.now
  end

  # pagination
  if params["items_per_page"]
    page = params["page"].to_i
    ipp = params["items_per_page"].to_i
    @@cached_streams[name][(page*ipp)...(page*ipp+ipp)]

  else
    @@cached_streams[name]

  end.to_json
end

get "/makes" do
  content_type 'application/json'

  stream = Gozer::Stream.new
  stream += Gozer::Stream::Atom.new "http://fast-crag-2176.herokuapp.com/rss"
  
  stream.to_json
end

get "/demo.html" do
  content_type 'text/html'

  demo_stream(params).map do |item|
    "<div class='stream-item' id='item-#{item.object_id}'>" +
    item.keys.map do |key| 
      "<span class='#{key}'>#{item[key]}</span>"
    end.join("\n") +
    "</div>"
  end.join("\n")
end
