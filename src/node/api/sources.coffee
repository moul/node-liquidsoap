{API} = require "../api"

# Creation operators, name in `create` params.

class API.Blank extends API.Private.Source
  @path: "/blank"

class API.Single extends API.Private.Source
  @path: "/single"

API.Request = {}

class API.Request.Queue extends API.Private.Source
  @path: "/request/queue"

  push: (requests, fn) =>
    requests = [requests] unless requests instanceof Array

    @http_request {
      method : "PUT",
      path   : "/sources/#{@name}/requests",
      query  : requests }, fn

class API.Request.Dynamic extends API.Private.Source
  @path: "/request/dynamic"

API.Input = {}

class API.Input.Http extends API.Private.Stateful
    @path: "/input/http"

