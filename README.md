Liquidsoap node controler
=========================

[![Build Status](https://travis-ci.org/savonet/node-liquidsoap.png?branch=master)](https://travis-ci.org/savonet/node-liquidsoap) [![GuardRails badge](https://badges.production.guardrails.io/moul/node-liquidsoap.svg)](https://www.guardrails.io)

This module uses [savonet/liquidsoap-controler](https://github.com/savonet/liquidsoap-controler) to provide
a rich and simple API to create and manipulate liquidsoap streams in nodeJS and in the browser.

Documentation
=============

The `liquidsoap` module contains the following classes:

* `Client` : Base client to communicate with an instance of `liquidsoap-controller`
* `API` : API of available sources, operators and outputs.

Basics
------

All sources, operators and output are created asynchronously. For instance:

```coffee
client = new Client
  auth : "user:password"
  host : "myserver"
  port : 8080

blank = null

conf =
  type : API.Blank
  name : "blank"

client.create conf, (err, sources) ->
  return console.dir err if err?

  {blank} = sources
```

By convention, all callback functions receive an error, if it occured, as first parameter.

Once you have created a base source, you can wrap it into one of the available operators, for instance:

```coffee
get = null

conf =
  type   : API.Metadata.Get
  name   : "get"
  source : blank

client.create conf, (err, sources) ->
  return console.dir err if err?

  {get} = sources

# Now you can get metadata!
get.get_metadata (err, metadata) ->
  return console.dir err if err?

  console.log "Metadata:"
  console.dir metadata
```

The `name` parameter above is optional. If no `name` is given, the new source will be named `"blank"`
as well. You can call `client.sources` (asynchronous call), to get the list of all defined sources.

Finally, you can plug a source into an output:

```coffee
ao = null

conf =
  type   : API.Output.Ao
  name   : "ao"
  source : get

client.create conf, (err, sources) ->
  return console.dir err if err?

  {ao} = sources
```

Chained creation
----------------

You can also chain sources creation using a single object. For instance, the example above rewrites as:
```coffee
ao = get = blank = null

conf =
  type : API.Output.Ao
  name : "ao"
  source :
    type : API.Metadata.Get
    name : "get"
    source :
      type : API.Blank
      name : "blank"

client.create conf, (err, sources) ->
  return console.dir err if err?

  {ao, get, blank} = sources
```

Alternative creation calls
--------------------------

The following creation calls are also supported:


#### Declare sources as `name => conf` associations.
```coffee
conf =
  blank :
    type : API.Blank
  queue :
    type : API.Request.Queue
  ao :
    type : API.Output.Ao
    source :
      type      : API.Input.Http
      uri       : "http://..."
      autostart : false

client.create conf, (err, sources) ->
  return console.dir err if err?

  {blank, queue, ao} = sources
```

#### Direct call to the base class
```coffee
blank = null

API.Blank.create client, { name : "blank" }, (err, sources) ->
  return console.dir err if err?

  {blank} = sources
```

TODO
====

More operators, support for encoders, support for `request.dynamic`, ...

