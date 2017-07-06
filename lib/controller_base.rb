require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = req.params.merge(route_params)
  end

  def already_built_response?
    @already_built_response
  end

  def redirect_to(url)
    raise 'cannot double render' if already_built_response?

    res.status = 302
    res.location = url
    @session.store_session(res)
    @already_built_response = true
  end

  def render_content(content, content_type)
    raise 'cannot double render' if already_built_response?

    res.write(content)
    res.set_header('Content-Type', content_type)
    session.store_session(res)
    @already_built_response = true
  end

  def render(template_name)
    path_to_file = "views/#{self.class.to_s.underscore}/#{template_name}.html.erb"
    file = File.read(path_to_file)
    template = ERB.new(file).result(binding)
    render_content(template, 'text/html')
  end

  def session
    @session ||= Session.new(req)
    @session
  end

  def invoke_action(action_name)
    self.send(action_name)
    render(action_name) unless already_built_response?
  end
end
