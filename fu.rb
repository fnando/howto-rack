require "rack"
require "rack/mount"
require "rack/contrib"
require "active_support/hash_with_indifferent_access"

class FU
  class App
    attr_reader :env
    attr_accessor :callback

    def initialize(callback)
      @callback = callback
    end

    def request
      @request ||= Rack::Request.new(env)
    end

    def params
      @params ||= begin
        params = request.params || {}
        params.merge!(request.env["rack.request.form_hash"] || {})
        params.merge!(request.env["rack.routing_args"] || {})
        ActiveSupport::HashWithIndifferentAccess.new(params)
      end
    end

    def call(env)
      @env = env
      instance_eval(&callback)
    end
  end

  def self.app(&block)
    new(&block).to_app
  end

  def initialize(&block)
    instance_eval(&block)
  end

  def middlewares
    @middlewares ||= []
  end

  def get(path, &block)
    match(path, "GET", &block)
  end

  def post(path, &block)
    match(path, "POST", &block)
  end

  def put(path, &block)
    match(path, "PUT", &block)
  end

  def delete(path, &block)
    match(path, "DELETE", &block)
  end

  def head(path, &block)
    match(path, "HEAD", &block)
  end

  def match(path, method = nil, &block)
    conditions = {path_info: compile_path(path)}
    conditions[:request_method] = method if method

    builder = Rack::Builder.new
    builder.use Rack::ETag
    builder.use Rack::ContentLength
    builder.use Rack::MethodOverride
    builder.use Rack::NestedParams

    middlewares.each do |middleware, args|
      builder.use middleware, *args
    end

    app = App.new(block)
    builder.run(app)

    route_set.add_route(builder, conditions)
  end

  def use(middleware, *args)
    middlewares << [middleware, args]
  end

  def to_app
    route_set.freeze
  end

  private
  def route_set
    @route_set ||= Rack::Mount::RouteSet.new
  end

  def compile_path(path)
    Rack::Mount::Strexp.compile Rack::Mount::Utils.normalize_path(path), {}, %w[/.?]
  end
end

app = FU.app do
  use Rack::Runtime

  get "/" do
    name = params.fetch(:name, "Rackers")

    [
      200,
      {"Content-Type" => "text/html"},
      ["Hello #{name}!"]
    ]
  end

  get "/:name" do
    [
      200,
      {"Content-Type" => "text/html"},
      ["Hello #{params[:name]}!"]
    ]
  end

  post "/" do
    name = params.fetch(:name, "Rackers")

    [
      200,
      {"Content-Type" => "text/html"},
      ["Hello #{name}! Post data sent!"]
    ]
  end
end

Rack::Handler::Thin.run app, :Port => 1234
