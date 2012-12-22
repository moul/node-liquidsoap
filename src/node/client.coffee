{b64, chain, stringify} = require "./utils"

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

