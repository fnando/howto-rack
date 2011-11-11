require "rack"

class MyApp
  def call(env)
    [
      200,
      {"Content-Type" => "text/plain"},
      ["Hello Rackers!"]
    ]
  end
end

app = Rack::Builder.app do
  use Rack::ContentLength

  map "/codeplane" do
    run MyApp.new
  end

  map "/howto" do
    run MyApp.new
  end
end

Rack::Handler::Thin.run app, :Port => 1234
