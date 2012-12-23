{API} = require "../api"

API.Output = {}

class API.Output.Ao          extends API.Private.Stateful
  @path: "/output/ao"

class API.Output.Dummy       extends API.Private.Stateful
  @path: "/output/dummy"

class API.Output.IcecastBase extends API.Private.Stateful
  @path: "/output/icecast"

API.Output.Icecast = (options = {}) ->
  object = API.Output.IcecastBase
  # TODO: options.encoder
  # TODO: options.mount
  object.path    = "/output/icecast.mp3.128"
  return object
