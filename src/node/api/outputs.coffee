{API} = require "../api"

API.Output = {}

class API.Output.Ao          extends API.Private.Stateful
  @path: "/output/ao"

class API.Output.Dummy       extends API.Private.Stateful
  @path: "/output/dummy"

API.Output.Icecast = (opts) ->
  output = API.Private.IcecastWrapper
  output.opts ?= {}
  output.opts.mount = opts['mount']
  for key, value of opts['encoder'].opts
    output.opts["encoder_#{key}"] = value
  output
