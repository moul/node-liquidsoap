// Generated by CoffeeScript 1.6.2
(function() {
  var API;

  API = require("../api").API;

  API.Encoder = {};

  API.Encoder.Mp3 = function(opts) {
    var encoder, _base, _base1, _base2, _ref, _ref1, _ref2;

    if (opts == null) {
      opts = {};
    }
    encoder = API.Private.Encoder;
    if ((_ref = (_base = encoder.opts).type) == null) {
      _base.type = 'mp3';
    }
    if ((_ref1 = (_base1 = encoder.opts).samplerate) == null) {
      _base1.samplerate = opts.samplerate;
    }
    if ((_ref2 = (_base2 = encoder.opts).bitrate) == null) {
      _base2.bitrate = opts.bitrate;
    }
    return encoder;
  };

}).call(this);
