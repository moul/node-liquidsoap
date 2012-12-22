{API} = require "../api"

# Fallback operator. Name in `create` params..

class API.Fallback extends API.Private.Source
  @path: "/fallback"

  @create: (client, opts, fn) ->
    sources = {}
    for key, source of opts.sources
      sources[key] = ""

    options      = opts.options || {}
    options.name = opts.name

    super client, { sources: sources, options: options}, fn

# Mapping operators (no name given in `create` function parameters)

API.Metadata = {}

class API.Metadata.Get extends API.Private.Source
  @path: "/get_metadata"

  get_metadata: (fn) =>
    http_options =
      method : "GET"
      path   : "/sources/#{@name}/metadata"

    @http_request http_options, fn

class API.Metadata.Set extends API.Private.Source
  @path: "/set_metadata"

  set_metadata: (metadata, fn) =>
    http_options =
      method : "PUT"
      path   : "/sources/#{@name}/metadata"
      query  : metadata
    @http_request http_options, fn
