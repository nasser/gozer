require "open-uri"

require "sinatra"
require "hashie"
require "json"

require_relative "lib/gozer/stream"
require_relative "lib/gozer/item"

require_relative "lib/atom/atom"
require_relative "lib/github/github"

get "/" do
  content_type 'application/json'

  stream = Gozer::Stream.new []
  stream += Gozer::Stream::Github.new "openFrameworks", "openFrameworks"
  stream += Gozer::Stream::Github.new "nasser", "zajal", "amsterdam"
  stream += Gozer::Stream::Atom.new "http://blog.nas.sr/rss"
  stream += Gozer::Stream::Atom.new "http://blog.zajal.cc/rss"

  stream.to_json
end
