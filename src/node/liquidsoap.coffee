{b64, chain, stringify, mixin} = require "./utils"

class module.exports.Client
  constructor: (@opts = {}) ->
    @auth = @opts.auth
    @host = @opts.host
    # For browserify..
    @scheme = @opts.scheme || "http"
    if @opts.scheme == "https"
      @http = require "https"
    else
      @http = require "http"
    @port = @opts.port || 80

  http_request: (opts, fn) =>
    expects = opts.expects || 200
    query   = opts.query
    options = opts.options || {}

    headers =
      "Accept" : "application/json"

    if @auth?
      headers["Authorization"] = "Basic #{b64 @auth}"

    opts =
      host    : @host
      port    : @port
      method  : opts.method
      path    : opts.path
      headers : headers
      scheme  : @scheme

    if query?
      query = JSON.stringify query

      opts.headers["Content-Type"]   = "application/json"
      opts.headers["Content-Length"] = query.length

    req = @http.request opts, (res) ->
      data = ""
      res.on "data", (buf) -> data += buf
      res.on "end", ->
        try
          data = JSON.parse data
        catch err

        if res.statusCode != expects
          err =
            code     : res.statusCode
            options  : opts
            query    : query
            response : data

          return fn err, null

        fn null, data

    req.end query

  create: (sources, fn) ->
    res = {}

    # Exec params, name create source name
    # with given param, ppossibly recursing
    # down to params.source and params.sources
    # if they exist.
    exec = (params, name, fn) =>
      return fn null unless params?

      # If no type is given, argument
      # is supposed to be already instanciated.
      unless params.type?
        res[name] = params
        return fn null

      chain params.sources, exec, (err) =>
        return fn err if err?

        exec params.source, name, (err) =>
          return fn err if err?
     
          if params.name?
            name = params.name
          else
            params.name = name

          # If params.source.name is defined,
          # pick this up for the source. Otherwise
          # use default name.
          if params.source?.name?
            source  = res[params.source.name]
          else
            source  = res[name]

          # If source does not exist yet (source creation,
          # e.g request.queue etc..), then use current client.
          source = source || this

          callback = (err, source) ->
            return fn err if err?

            res[name] = source
            fn null, name

          params.type.create source, params, callback

    # Create all top-level sources
    chain sources, exec, (err) ->
      return fn err, null if err?

      fn null, res

  sources: (fn) ->
    @http_request {
      method : "GET"
      path   : "/sources" }, fn

class Source
  @create: (client, opts, fn) ->
    res = new this client, opts

    # Cleanup options
    delete opts.type

    # Source/sources
   
    # Do nothing if opts.sources is defined.
    unless opts.sources?
      # First, try opts.source.name if it exists
      if opts.source?.name?
        opts.source = opts.source.name
      # Then try client.name if it exists
      else if client.name?
        opts.source = client.name
      # Or else, delete it..
      else
        delete opts.source

    client.http_request {
      method  : "POST",
      path    : @path,
      query   : stringify(opts),
      expects : 201 }, (err) ->
        return fn err, null if err?

        fn null, res

  constructor: (src, opts) ->
    if opts.sources?
      this.name = opts.options.name
    else
      this.name = opts.name ||= src.name

    mixin src, this

    # Do no heritate sources method.
    delete this.sources

    this

  # Generic endpoints
  skip: (fn) ->
    @http_request {
      method : "PUT",
      path   : "/sources/#{@name}/skip"}, fn

  shutdown: (fn) ->
    @http_request {
      method : "DELETE",
      path   : "/sources/#{@name}"}, fn

# Creation operators, name in `create` params.

class module.exports.Blank extends Source
  @path: "/blank"

class module.exports.Single extends Source
  @path: "/single"

module.exports.Request = {}

class module.exports.Request.Queue extends Source
  @path: "/request/queue"

  push: (requests, fn) =>
    requests = [requests] unless requests instanceof Array

    @http_request {
      method : "PUT",
      path   : "/sources/#{@name}/requests",
      query  : requests }, fn

class module.exports.Request.Dynamic extends Source
  @path: "/request/dynamic"

# Fallback operator. Name in `create` params..

class module.exports.Fallback extends Source
  @path: "/fallback"

  @create: (client, opts, fn) ->
    sources = {}
    for key, source of opts.sources
      sources[key] = ""

    options      = opts.options || {}
    options.name = opts.name

    super client, { sources: sources, options: options}, fn

# Mapping operators (no name given in `create` function parameters)

module.exports.Metadata = {}

class module.exports.Metadata.Get extends Source
  @path: "/get_metadata"

  get_metadata: (fn) =>
    @http_request {
      method : "GET",
      path   : "/sources/#{@name}/metadata" }, fn

class module.exports.Metadata.Set extends Source
  @path: "/set_metadata"

  set_metadata: (metadata, fn) =>
    @http_request {
      method : "PUT",
      path   : "/sources/#{@name}/metadata",
      query  : metadata }, fn

class Stateful extends Source
  start: (fn) ->
    @http_request {
      method : "PUT",
      path   : "/sources/#{@name}/start" }, fn

  stop: (fn) ->
    @http_request {
      method : "PUT",
      path   : "/sources/#{@name}/stop" }, fn

  status: (fn) ->
    @http_request {
      method : "GET",
      path   : "/sources/#{@name}/status" }, fn

module.exports.Input = {}

class module.exports.Input.Http extends Stateful
  @path: "/input/http"

module.exports.Output = {}

class module.exports.Output.Ao extends Stateful
  @path: "/output/ao"

class module.exports.Output.Dummy extends Stateful
  @path: "/output/dummy"
