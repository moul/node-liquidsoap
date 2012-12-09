{Client, Blank} = require "../src/node/liquidsoap"

describe "Sources creation", ->
  beforeEach ->
    @client = new Client

    spyOn(@client, "http_request").andCallFake (@params, fn) =>
      fn "done-test-create"

  it "can create a blank source", ->
    @fn = ->

    spyOn this, "fn"

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
 
    expect(@fn).toHaveBeenCalledWith "done-test-create", null
