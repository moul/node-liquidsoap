// Generated by CoffeeScript 1.3.1
(function() {
  var Source, Stateful, b64, chain, mixin, stringify, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  _ref = require("./utils"), b64 = _ref.b64, chain = _ref.chain, stringify = _ref.stringify, mixin = _ref.mixin;

  module.exports.Client = (function() {

    Client.name = 'Client';

    function Client(opts) {
      this.opts = opts;
      this.http_request = __bind(this.http_request, this);

      this.auth = opts.auth;
      this.host = opts.host;
      if (opts.scheme === "http") {
        this.http = require("http");
      } else {
        this.http = require("https");
      }
      this.port = opts.port || 80;
    }

    Client.prototype.http_request = function(opts, fn) {
      var expects, headers, query, req;
      expects = opts.expects || 200;
      query = opts.query;
      headers = {
        "Accept": "application/json"
      };
      if (this.auth != null) {
        headers["Authorization"] = "Basic " + (b64(this.auth));
      }
      opts = {
        host: this.host,
        port: this.port,
        method: opts.method,
        path: opts.path,
        headers: headers
      };
      if (query != null) {
        query = JSON.stringify(query);
        opts.headers["Content-Type"] = "application/json";
        opts.headers["Content-Length"] = query.length;
      }
      req = this.http.request(opts, function(res) {
        var data;
        data = "";
        res.on("data", function(buf) {
          return data += buf;
        });
        return res.on("end", function() {
          try {
            data = JSON.parse(data);
          } catch (err) {

          }
          if (res.statusCode !== expects) {
            err = {
              code: res.statusCode,
              data: data,
              options: opts
            };
            return fn(err, null);
          }
          return fn(null, data);
        });
      });
      return req.end(query);
    };

    Client.prototype.create = function(sources, fn) {
      var exec, res,
        _this = this;
      res = {};
      exec = function(params, name, fn) {
        if (params == null) {
          return fn(null);
        }
        if (params.type == null) {
          res[name] = params;
          return fn(null);
        }
        return chain(params.sources, exec, function(err) {
          if (err != null) {
            return fn(err);
          }
          return exec(params.source, name, function(err) {
            var source;
            if (err != null) {
              return fn(err);
            }
            source = res[name] || _this;
            return params.type.create(name, source, params, function(err, source) {
              if (err != null) {
                return fn(err);
              }
              res[name] = source;
              return fn(null);
            });
          });
        });
      };
      return chain(sources, exec, function(err) {
        if (err != null) {
          return fn(err, null);
        }
        return fn(null, res);
      });
    };

    return Client;

  })();

  Source = (function() {

    Source.name = 'Source';

    function Source() {}

    Source.create = function(name, dst, src) {
      var res;
      res = new dst;
      res.name = name;
      mixin(src, res);
      return res;
    };

    Source.prototype.skip = function(fn) {
      return this.http_request({
        method: "POST",
        path: "/sources/" + this.name + "/skip"
      }, fn);
    };

    Source.prototype.shutdown = function(fn) {
      return this.http_request({
        method: "DELETE",
        path: "/sources/" + this.name
      }, fn);
    };

    return Source;

  })();

  module.exports.Blank = (function(_super) {

    __extends(Blank, _super);

    Blank.name = 'Blank';

    function Blank() {
      return Blank.__super__.constructor.apply(this, arguments);
    }

    Blank.create = function(name, source, opts, fn) {
      var res;
      if (fn == null) {
        fn = opts;
        opts = {};
      }
      res = Source.create(name, Blank, source);
      return res.http_request({
        method: "PUT",
        path: "/blank/" + res.name,
        query: opts.duration || 0
      }, function(err) {
        if (err != null) {
          return fn(err, null);
        }
        return fn(null, res);
      });
    };

    return Blank;

  }).call(this, Source);

  module.exports.Single = (function(_super) {

    __extends(Single, _super);

    Single.name = 'Single';

    function Single() {
      return Single.__super__.constructor.apply(this, arguments);
    }

    Single.create = function(name, source, opts, fn) {
      var res;
      if (fn == null) {
        fn = opts;
        opts = {};
      }
      res = Source.create(name, Single, source);
      return res.http_request({
        method: "PUT",
        path: "/single/" + res.name,
        query: opts.uri || 0
      }, function(err) {
        if (err != null) {
          return fn(err, null);
        }
        return fn(null, res);
      });
    };

    return Single;

  }).call(this, Source);

  module.exports.Input = {};

  module.exports.Input.Http = (function(_super) {

    __extends(Http, _super);

    Http.name = 'Http';

    function Http() {
      return Http.__super__.constructor.apply(this, arguments);
    }

    Http.create = function(name, source, opts, fn) {
      var res;
      if (fn == null) {
        fn = opts;
        opts = {};
      }
      res = Source.create(name, Http, source);
      mixin(Stateful, res);
      return res.http_request({
        method: "PUT",
        path: "/input/http/" + res.name,
        query: stringify(opts)
      }, function(err) {
        if (err != null) {
          return fn(err, null);
        }
        return fn(null, res);
      });
    };

    return Http;

  }).call(this, Source);

  module.exports.Request = {};

  module.exports.Request.Queue = (function(_super) {

    __extends(Queue, _super);

    Queue.name = 'Queue';

    function Queue() {
      this.push = __bind(this.push, this);
      return Queue.__super__.constructor.apply(this, arguments);
    }

    Queue.create = function(name, client, opts, fn) {
      var res;
      if (fn == null) {
        fn = opts;
        opts = {};
      }
      res = Source.create(name, Queue, client);
      return res.http_request({
        method: "PUT",
        path: "/request/queue/" + res.name
      }, function(err) {
        if (err != null) {
          return fn(err, null);
        }
        return fn(null, res);
      });
    };

    Queue.prototype.push = function(requests, fn) {
      if (!(requests instanceof Array)) {
        requests = [requests];
      }
      return this.http_request({
        method: "POST",
        path: "/sources/" + this.name + "/requests",
        query: requests
      }, fn);
    };

    return Queue;

  }).call(this, Source);

  module.exports.Metadata = {};

  module.exports.Metadata.Get = (function(_super) {

    __extends(Get, _super);

    Get.name = 'Get';

    function Get() {
      this.get_metadata = __bind(this.get_metadata, this);
      return Get.__super__.constructor.apply(this, arguments);
    }

    Get.create = function(name, source, opts, fn) {
      var res;
      if (fn == null) {
        fn = opts;
        opts = {};
      }
      res = Source.create(name, Get, source);
      return res.http_request({
        method: "PUT",
        path: "/get_metadata/" + source.name
      }, function(err) {
        if (err != null) {
          return fn(err, null);
        }
        return fn(null, res);
      });
    };

    Get.prototype.get_metadata = function(fn) {
      return this.http_request({
        method: "GET",
        path: "/sources/" + this.name + "/metadata"
      }, fn);
    };

    return Get;

  }).call(this, Source);

  module.exports.Metadata.Set = (function(_super) {

    __extends(Set, _super);

    Set.name = 'Set';

    function Set() {
      this.set_metadata = __bind(this.set_metadata, this);
      return Set.__super__.constructor.apply(this, arguments);
    }

    Set.create = function(name, source, opts, fn) {
      var res;
      if (fn == null) {
        fn = opts;
        opts = {};
      }
      res = Source.create(name, Set, source);
      return res.http_request({
        method: "PUT",
        path: "/set_metadata/" + source.name
      }, function(err) {
        if (err != null) {
          return fn(err, null);
        }
        return fn(null, res);
      });
    };

    Set.prototype.set_metadata = function(metadata, fn) {
      return this.http_request({
        method: "POST",
        path: "/sources/" + this.name + "/metadata",
        query: metadata
      }, fn);
    };

    return Set;

  }).call(this, Source);

  Stateful = (function() {

    Stateful.name = 'Stateful';

    function Stateful() {}

    Stateful.start = function(fn) {
      return this.http_request({
        method: "POST",
        path: "/sources/" + this.name + "/start"
      }, fn);
    };

    Stateful.stop = function(fn) {
      return this.http_request({
        method: "POST",
        path: "/sources/" + this.name + "/stop"
      }, fn);
    };

    Stateful.status = function(fn) {
      return this.http_request({
        method: "GET",
        path: "/sources/" + this.name + "/status"
      }, fn);
    };

    return Stateful;

  })();

  module.exports.Output = {};

  module.exports.Output.Ao = (function(_super) {

    __extends(Ao, _super);

    Ao.name = 'Ao';

    function Ao() {
      return Ao.__super__.constructor.apply(this, arguments);
    }

    Ao.create = function(name, source, opts, fn) {
      var res;
      if (fn == null) {
        fn = opts;
        opts = {};
      }
      res = Source.create(name, Ao, source);
      mixin(Stateful, res);
      return res.http_request({
        method: "PUT",
        path: "/output/ao/" + source.name
      }, function(err) {
        if (err != null) {
          return fn(err, null);
        }
        return fn(null, res);
      });
    };

    return Ao;

  }).call(this, Source);

  module.exports.Output.Dummy = (function(_super) {

    __extends(Dummy, _super);

    Dummy.name = 'Dummy';

    function Dummy() {
      return Dummy.__super__.constructor.apply(this, arguments);
    }

    Dummy.create = function(name, source, opts, fn) {
      var res;
      if (fn == null) {
        fn = opts;
        opts = {};
      }
      res = Source.create(name, Dummy, source);
      mixin(Stateful, res);
      return res.http_request({
        method: "PUT",
        path: "/output/dummy/" + source.name
      }, function(err) {
        if (err != null) {
          return fn(err, null);
        }
        return fn(null, res);
      });
    };

    return Dummy;

  }).call(this, Source);

  module.exports.Fallback = (function(_super) {

    __extends(Fallback, _super);

    Fallback.name = 'Fallback';

    function Fallback() {
      return Fallback.__super__.constructor.apply(this, arguments);
    }

    Fallback.create = function(name, client, opts, fn) {
      var key, options, res, source, sources;
      if (fn == null) {
        fn = opts;
        opts = {};
      }
      res = Source.create(name, Fallback, client);
      sources = (function() {
        var _ref1, _results;
        _ref1 = opts.sources;
        _results = [];
        for (key in _ref1) {
          source = _ref1[key];
          _results.push(key);
        }
        return _results;
      })();
      options = opts.options || [];
      return res.http_request({
        method: "PUT",
        path: "/fallback/" + name,
        query: {
          sources: sources,
          options: options
        }
      }, function(err) {
        if (err != null) {
          return fn(err, null);
        }
        return fn(null, res);
      });
    };

    return Fallback;

  }).call(this, Source);

}).call(this);