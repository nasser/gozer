require "open-uri"

require "sinatra"
require "hashie"
require "json"

require_relative "lib/gozer/stream"
require_relative "lib/gozer/item"

require_relative "lib/atom/atom"
require_relative "lib/github/github"
require_relative "lib/tumblr/tumblr"

def demo_stream
  stream = Gozer::Stream.new []
  # stream += Gozer::Stream::Github.new "openFrameworks", "openFrameworks"
  # stream += Gozer::Stream::Github.new "nasser", "zajal", "amsterdam"
  # stream += Gozer::Stream::Atom.new "http://blog.nas.sr/rss"
  Gozer::Stream::Tumblr.api_key = "zZjfj7R30K17nG35Nqw6OXAN3QMxHp31veEaf1frJ7xzIAqj3p"
  stream += Gozer::Stream::Tumblr.new "wearableweapons.tumblr.com"  

  stream
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