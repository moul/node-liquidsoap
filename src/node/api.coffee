{stringify, mixin} = require "./utils"

# Base API namespace

module.exports.API = API = {}

# Private API

API.Private = {}

# Base source class.

class API.Private.Source
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

    options =
      method  : "POST"
      path    : @path
      query   : stringify opts
      expects : 201

    res.http_request options, (err) ->
        return fn err, null if err?

        fn null, res

  constructor: (src, opts) ->
    if opts.sources?
      @name = opts.options.name
    else
      @name = opts.name ||= src.name

    mixin src, this

    # Do no heritate sources method.
    delete @sources

    this

  # Generic endpoints
  skip: (fn) ->
    options =
      method : "PUT"
      path   : "/sources/#{@name}/skip"

    @http_request options, fn

  shutdown: (fn) ->
    options =
      method : "DELETE"
      path   : "/sources/#{@name}"

    @http_request options, fn

class API.Private.Stateful extends API.Private.Source
  start: (fn) ->
    options =
      method : "PUT"
      path   : "/sources/#{@name}/start"

    @http_request options, fn

  stop: (fn) ->
    options =
      method : "PUT"
      path   : "/sources/#{@name}/stop"
    @http_request options, fn

  status: (fn) ->
    options =
      method : "GET"
      path   : "/sources/#{@name}/status"

    @http_request options, fn
