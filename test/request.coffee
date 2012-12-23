{ Client, API} = require "./liquidsoap"

{ Request,  Output,
  Input,    Metadata,
  Fallback, Single,
  Encoder,  Blank } = API

{chain}             = require "./utils"

opts =
  auth: "test:test"
  host: "localhost"
  port: 8080

client = new Client opts

sources = {}
sources.ice128 =
    type   : Output.Icecast
      mount     : '/test.mp3'
      encoder   : Encoder.Mp3
        bitrate    : 128
        samplerate : 44100
    source :
      type      : Input.Http
      uri       : "http://radiopi.org:8080/reggae"
sources.ice32 =
    type   : Output.Icecast
      mount     : '/test2.mp3'
      encoder   : Encoder.Mp3
        bitrate    : 32
        samplerate : 44100
    source :
      type      : Input.Http
      uri       : "http://radiopi.org:8080/reggae"
sources.foo =
    type   : Output.Ao
    source :
      type   : Metadata.Get
      source :
        type   : Metadata.Set
        source :
          type    : Fallback
          name    : "fallback"
          sources :
            request1 :
              type : Request.Queue
            request2 :
              type : Request.Queue
            radiopi  :
              type      : Input.Http
              uri       : "http://radiopi.org:8080/reggae"
              autostart : false
sources.dummy =
    type   : Output.Dummy
    source :
      type    : Fallback
      sources :
        bar :
          type     : Blank
          duration : 3
        bla :
          type : Single
          uri  : "say:it works!"
        gni :
          type : Request.Dynamic
          uri  : "lastfm://globaltags/rocksteady"

pushRequest = (source, request, fn) ->
 source.push request, (err) ->
   return console.log "Error pushing request to request source" if err?

   fn()

changeMetadata = (source, value, fn) ->
 set_meta = (next) ->
   console.log "Setting artist to \"#{value}\" on source #{source.name}"

   source.set_metadata artist: value, (err) ->
     return "Error setting metadata." if err?

     setTimeout next, 500 if next?

  get_meta = (next) ->
    source.get_metadata (err, res) ->
      return console.log "Error grabbing metadata" if err?

      console.log """
        Latest metadata on #{source.name}:
        #{JSON.stringify res, undefined, 2}
                  """

      setTimeout next, 500 if next?

  cb = ->
    get_meta ->
      set_meta ->
        get_meta ->
          fn()

  setTimeout cb, 1000

checkState = (source, fn) ->
  source.status (err, res) ->
    return fn err if err?

    console.log "Current status for #{source.name}:"
    console.dir res

    source.start (err) ->
      return fn err if err?

      source.status (err, res) ->
        console.log "New status for #{source.name}:"
        console.dir res

        fn null

client.create sources, (err, sources) ->
  if err?
    console.log "Error while creating sources:"
    return console.dir err

  # process.exit 0 # Temporarily stop the test here

  # Test case where source is already instanciated
  dummy2 =
    dummy2 :
      type   : Output.Dummy
      source : sources.bar

  client.create dummy2, (err, dummy2) ->
    if err?
      console.log "Error while creating dummy source."
      return console.dir err

    sources.dummy2 = dummy2.dummy2

  client.sources (err, sources) ->
    if err?
      console.log "Error while grabbing list of defined sources."
      return console.dir err

    console.log "All sources:"
    console.dir sources

  if err?
    console.log "Error while creating sources:"
    return console.dir err

  pushRequest sources.request1, "/tmp/foo.mp3", ->
    pushRequest sources.request2, "/tmp/bla.mp3", ->
      changeMetadata sources.foo, "foo", ->
        sources.request1.skip (err) ->
          if err?
            console.log "Error while skipping on request1:"
            return console.dir err

          checkState sources.radiopi, (err) ->
            if err?
              console.log "Error while checking radiopi's status:"
              console.dir err

            cb = ->
              sources.fallback.skip (err) ->
                if err?
                  console.log "Error while skipping on fallback:"
                  return console.dir err

                process = (source, name, fn) ->
                  source.shutdown (err) ->
                    if err
                      return fn
                        name : name
                        err  : err

                    fn()

                chain sources, process, (err) ->
                  if err?
                    console.log "Error while shuting down #{err.name}:"
                    return console.dir err.err

                  console.log "All Good Folks!"

            setTimeout cb, 1000
