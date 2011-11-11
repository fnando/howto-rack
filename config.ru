class MyApp
  def call(env)
    [
      200,
      {"Content-Type" => "text/plain"},
      ["Hello Rackers!"]
    ]
  end
end

use Rack::ContentLength
use Rack::Lint

run MyApp.new
