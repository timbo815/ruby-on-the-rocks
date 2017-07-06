class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    req.path =~ pattern && req.request_method.downcase.to_sym == http_method
  end

  def run(req, res)
    match_data = pattern.match(req.path)
    keys = match_data.names
    values = match_data.captures
    route_params = Hash[keys.zip(values)]

    controller = controller_class.new(req, res, route_params)
    controller.invoke_action(action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    route = Route.new(pattern, method, controller_class, action_name)
    @routes << route
  end

  # method for definining routes. Within a block passed to instance_eval
  # self returns the object that the method is being called on, ie. the router instance
  def draw(&proc)
    instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    route = @routes.detect { |route| route.matches?(req) }
    route ? route : nil
  end

  def run(req, res)
    route = match(req)
    if route
      result = route.run(req, res)
    else
      res.status = 404
    end
  end
end
