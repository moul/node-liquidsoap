{Blank, Client, Output} = require "../src/node/liquidsoap"

describe "Sources creation", ->
  beforeEach ->
    @client     = new Client
    
    @args       = null
    @fn         = ->
    @HttpParams = null
    @httpArgs   = null
    @type       = null

    spyOn(@client, "http_request").andCallFake (@httpParams, fn) =>
      fn null

    spyOn(this, "fn").andCallFake (err, sources) =>
      expect(err).toBeNull()

      source = sources[@name]

      expect(source).toBeDefined()
      expect(source.name).toEqual @name

      expect(source instanceof @type).toBeTruthy()

  afterEach ->
    @client.create @args, @fn

    expect(@fn).toHaveBeenCalled()

    expect(@httpParams).toEqual @httpArgs

    @client = @args = @fn = @httpParams = @httpArgs = @type = null

  it "can create a blank source", ->
    @name  = "blank"
    @type  = Blank
    @args  =
      blank :
        type     : Blank
        duration : 3

    @httpArgs =
      method  : "POST",
      path    : "/blank"
      query   :
        duration : "3"
        name     : "blank"
      expects : 201

  it "can create an output.ao source", ->
    @name = "ao"
    @type = Output.Ao

    @client.name = "foo"

    @args =
      ao :
        type   : Output.Ao
        source : @client

    @httpArgs =
      method  : "POST",
      path    : "/output/ao"
      query   :
        name   : "ao"
        source : "foo"
      expects : 201
