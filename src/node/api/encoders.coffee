{API} = require "../api"

API.Encoder = {}

API.Encoder.Mp3 = (opts = {}) ->
  encoder = API.Private.Encoder
  # TODO: check bitrate, samplerate (wikipedia)
  encoder.opts.type       ?= 'mp3'
  encoder.opts.samplerate ?= opts.samplerate
  encoder.opts.bitrate    ?= opts.bitrate
  encoder

#class API.Encoder.Vorbis       extends API.Private.Encoder
#  @type: 'vorbis'

#class API.Encoder.Ogg          extends API.Private.Encoder
#  @type: 'ogg'

#class API.Encoder.AACPlus      extends API.Private.Encoder
#  @type: 'aacplus'
