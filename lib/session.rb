require 'json'

class Session
  def initialize(req)
    cookie = req.cookies['_ruby_on_the_rocks']
    @cookie = cookie ? JSON.parse(cookie) : {}
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  def store_session(res)
    res.set_cookie('_ruby_on_the_rocks', {
      :path => '/',
      :value => @cookie.to_json
      }
    )
  end
end
