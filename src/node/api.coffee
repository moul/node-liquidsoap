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

    res.http_request {
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

class API.Private.Stateful extends API.Private.Source
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
