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

Rack::Handler::Thin.run MyApp.new, :Port => 1234
