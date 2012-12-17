{Client, Output, Fallback} = require "../src/node/liquidsoap"

describe "Chaining sources", ->
  beforeEach ->
    @client     = new Client

  afterEach ->
    @client = null

  describe "Outputs", ->
    beforeEach ->
      @Source =
        create: ->

      spyOn(@Source, "create").andCallFake (client, args, fn) ->
        fn null, new Client

    afterEach ->
      @Source = null

    for output, klass of Output
      it "should create a Output.#{output} output and its source with same name
          when passing a source parameter and no name for the source", ->
        sources =
          foo :
            type : klass
            source :
              type : @Source

        spyOn(klass, "create").andCallFake (client, opts, fn) =>
          expect(opts?.source?.name).toEqual "foo"
          expect(opts?.source?.type).toEqual @Source

        @client.create sources

        expect(klass.create).toHaveBeenCalled()

        expect(@Source.create).toHaveBeenCalled()

      it "should create a Output.#{output} output and its source with its own name
          when passing a source and name parameters for the source", ->
        sources =
          foo :
            type : klass
            source :
              type : @Source
              name : "bar"

        spyOn(klass, "create").andCallFake (client, opts, fn) =>
          expect(opts?.source?.name).toEqual "bar"
          expect(opts?.source?.type).toEqual @Source

        @client.create sources

        expect(klass.create).toHaveBeenCalled()

        expect(@Source.create).toHaveBeenCalled()

      it "should create a Output.#{output} output but not its source
          when passing an instantiated source parameter", ->
        sources =
          foo :
            type   : klass
            source : @client

        spyOn(klass, "create").andCallFake (client, opts, fn) =>
          expect(opts?.source).toEqual @client

        @client.create sources

        expect(klass.create).toHaveBeenCalled()

        expect(@Source.create).not.toHaveBeenCalled()

  describe "Operators", ->
    beforeEach ->
      @SourceA =
        create: ->

      spyOn(@SourceA, "create").andCallFake (client, args, fn) ->
        fn null, new Client

      @SourceB =
        create: ->

      spyOn(@SourceB, "create").andCallFake (client, args, fn) ->
        fn null, new Client

    afterEach ->
      @SourceA = @SourceB = null

    it "should create a fallback source and its sources", ->
      sources =
        foo :
          type : Fallback
          sources :
            lolol:
              type : @SourceA
            lalal:
              type : @SourceB

      spyOn(Fallback, "create").andCallFake (client, opts, fn) =>
        expect(opts?.sources?.lolol?.type).toEqual @SourceA
        expect(opts?.sources?.lalal?.type).toEqual @SourceB

      @client.create sources

      expect(Fallback.create).toHaveBeenCalled()

      expect(@SourceA.create).toHaveBeenCalled()
      expect(@SourceB.create).toHaveBeenCalled()

    it "should create a fallback source and only non-instantiated sources", ->
      sources =
        foo :
          type : Fallback
          sources :
            lolol:
              type : @SourceA
            lalal: @client

      spyOn(Fallback, "create").andCallFake (client, opts, fn) =>
        expect(opts?.sources?.lolol?.type).toEqual @SourceA
        expect(opts?.sources?.lalal).toEqual @client

      @client.create sources

      expect(Fallback.create).toHaveBeenCalled()

      expect(@SourceA.create).toHaveBeenCalled()
      expect(@SourceB.create).not.toHaveBeenCalled()
