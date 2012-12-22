{Client} = require "./client"
{API}    = require "./api"

require "./api/sources"
require "./api/operators"
require "./api/outputs"

module.exports =
  Client : Client
  API    : API
