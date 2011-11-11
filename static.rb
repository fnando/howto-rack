require "rack"

app = Rack::Builder.new do
  use Rack::Static,
    urls: {"/" => "index.html"},
    root: "public"

  run Rack::URLMap.new({
    "/" => Rack::Directory.new("public")
  })
end

Rack::Handler::Thin.run app, :Port => 1234
