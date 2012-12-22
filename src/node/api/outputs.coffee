{API} = require "../api"

API.Output = {}

class API.Output.Ao extends API.Private.Stateful
  @path: "/output/ao"

class API.Output.Dummy extends API.Private.Stateful
  @path: "/output/dummy"
