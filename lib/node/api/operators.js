// Generated by CoffeeScript 1.6.2
(function() {
  var API, _ref, _ref1, _ref2,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  API = require("../api").API;

  API.Fallback = (function(_super) {
    __extends(Fallback, _super);

    function Fallback() {
      _ref = Fallback.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Fallback.path = "/fallback";

    Fallback.create = function(client, opts, fn) {
      var key, options, source, sources, _ref1;

      sources = {};
      _ref1 = opts.sources;
      for (key in _ref1) {
        source = _ref1[key];
        sources[key] = "";
      }
      options = opts.options || {};
      options.name = opts.name;
      return Fallback.__super__.constructor.create.call(this, client, {
        sources: sources,
        options: options
      }, fn);
    };

    return Fallback;

  })(API.Private.Source);

  API.Metadata = {};

  API.Metadata.Get = (function(_super) {
    __extends(Get, _super);

    function Get() {
      this.get_metadata = __bind(this.get_metadata, this);      _ref1 = Get.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Get.path = "/get_metadata";

    Get.prototype.get_metadata = function(fn) {
      var options;

      options = {
        method: "GET",
        path: "/sources/" + this.name + "/metadata"
      };
      return this.http_request(options, fn);
    };

    return Get;

  })(API.Private.Source);

  API.Metadata.Set = (function(_super) {
    __extends(Set, _super);

    function Set() {
      this.set_metadata = __bind(this.set_metadata, this);      _ref2 = Set.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    Set.path = "/set_metadata";

    Set.prototype.set_metadata = function(metadata, fn) {
      var options;

      options = {
        method: "PUT",
        path: "/sources/" + this.name + "/metadata",
        query: metadata
      };
      return this.http_request(options, fn);
    };

    return Set;

  })(API.Private.Source);

}).call(this);
