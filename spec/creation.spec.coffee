{Client, Blank} = require "../src/node/liquidsoap"

describe "Sources creation", ->
  beforeEach ->
    @client = new Client
    @fn     = ->

    spyOn(@client, "http_request").andCallFake (@params, fn) =>
      fn "done-test-create"

    spyOn this, "fn"

  afterEach ->
    expect(@fn).toHaveBeenCalledWith "done-test-create", null

    @client = @params = @fn = null

  it "can create a blank source", ->
    @client.create { blank:
      type     : Blank
      duration : 3
    }, @fn

    expect(@params).toEqual
      method  : "POST",
      path    : "/blank"
      query   :
        duration: "3"
        name:     "blank"
      expects : 201
