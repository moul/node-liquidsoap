{Blank,   Client,
 Input,   Output, 
 Request, Single} = require "../src/node/liquidsoap"

describe "Creation", ->
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

  describe "Sources", ->
    it "can create a blank source with name as key", ->
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

    it "can create a blank source with name in params", ->
      @name  = "blank"
      @type  = Blank
      @args  = [
        type     : Blank
        name     : "blank"
        duration : 3
      ]

      @httpArgs =
        method  : "POST",
        path    : "/blank"
        query   :
          duration : "3"
          name     : "blank"
        expects : 201

    it "can create a single source with name as key", ->
      @name  = "single"
      @type  = Single
      @args  =
        single :
          type : Single
          uri  : "fake://uri"

      @httpArgs =
        method  : "POST",
        path    : "/single"
        query   :
          name : "single"
          uri  : "fake://uri"
        expects : 201

    it "can create a single source with name in params", ->
      @name  = "single"
      @type  = Single
      @args  = [
        type : Single
        name : "single"
        uri  : "fake://uri"
      ]

      @httpArgs =
        method  : "POST",
        path    : "/single"
        query   :
          name : "single"
          uri  : "fake://uri"
        expects : 201

    it "can create a request.queue source with name as key", ->
      @name  = "queue"
      @type  = Request.Queue
      @args  =
        queue :
          type : Request.Queue

      @httpArgs =
        method  : "POST",
        path    : "/request/queue"
        query   :
          name : "queue"
        expects : 201

    it "can create a request.queue source with name in params", ->
      @name  = "queue"
      @type  = Request.Queue
      @args  = [
        type : Request.Queue
        name : "queue"
      ]

      @httpArgs =
        method  : "POST",
        path    : "/request/queue"
        query   :
          name : "queue"
        expects : 201

    it "can create a request.dynamic source with name as key", ->
      @name  = "dynamic"
      @type  = Request.Dynamic
      @args  =
        dynamic :
          type : Request.Dynamic
          uri  : "fake://uri"

      @httpArgs =
        method  : "POST",
        path    : "/request/dynamic"
        query   :
          name : "dynamic"
          uri  : "fake://uri"
        expects : 201

    it "can create a request.dynamic source with name in params", ->
      @name  = "dynamic"
      @type  = Request.Dynamic
      @args  = [
        type : Request.Dynamic
        name : "dynamic"
        uri  : "fake://uri"
      ]

      @httpArgs =
        method  : "POST",
        path    : "/request/dynamic"
        query   :
          name : "dynamic"
          uri  : "fake://uri"
        expects : 201

    it "can create an input.http source with name as key", ->
      @name  = "http"
      @type  = Input.Http
      @args  =
        http :
          type      : Input.Http
          uri       : "fake://uri"
          autostart : false

      @httpArgs =
        method  : "POST",
        path    : "/input/http"
        query   :
          name      : "http"
          uri       : "fake://uri"
          autostart : "false"
        expects : 201

    it "can create a input.http source with name in params", ->
      @name  = "http"
      @type  = Input.Http
      @args  = [
        type      : Input.Http
        name      : "http"
        uri       : "fake://uri"
        autostart : false
      ]

      @httpArgs =
        method  : "POST",
        path    : "/input/http"
        query   :
          name      : "http"
          uri       : "fake://uri"
          autostart : "false"
        expects : 201

  describe "Outputs", ->
    it "can create a dummy output with name as key", ->
      @name  = "dummy"
      @type  = Output.Dummy
      @args  =
        dummy :
          type   : Output.Dummy
          source : @client

      @client.name = "bla"

      @httpArgs =
        method  : "POST",
        path    : "/output/dummy"
        query   :
          name   : "dummy"
          source : "bla"
        expects : 201

    it "can create a dummy source with name in params", ->
      @name  = "dummy"
      @type  =  Output.Dummy
      @args  = [
        type   : Output.Dummy
        name   : "dummy"
        source : @client 
      ]

      @client.name = "bla"

      @httpArgs =
        method  : "POST",
        path    : "/output/dummy"
        query   :
          name   : "dummy"
          source : "bla"
        expects : 201

    it "can create an ao output with name as key", ->
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

    it "can create an ao output with name in params", ->
      @name = "ao"
      @type = Output.Ao

      @client.name = "foo"

      @args = [
        type   : Output.Ao
        name   : "ao"
        source : @client
      ]

      @httpArgs =
        method  : "POST",
        path    : "/output/ao"
        query   :
          name   : "ao"
          source : "foo"
        expects : 201
