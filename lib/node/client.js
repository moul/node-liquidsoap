// Generated by CoffeeScript 1.6.2
(function() {
  var b64, chain, stringify, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ref = require("./utils"), b64 = _ref.b64, chain = _ref.chain, stringify = _ref.stringify;

  module.exports.Client = (function() {
    function Client(opts) {
      this.opts = opts != null ? opts : {};
      this.http_request = __bind(this.http_request, this);
      this.auth = this.opts.auth;
      this.host = this.opts.host;
      this.scheme = this.opts.scheme || "http";
      if (this.opts.scheme === "https") {
        this.http = require("https");
      } else {
        this.http = require("http");
      }
      this.port = this.opts.port || 80;
    }

    Client.prototype.http_request = function(opts, fn) {
      var expects, headers, options, query, req;

      expects = opts.expects || 200;
      query = opts.query;
      options = opts.options || {};
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
        headers: headers,
        scheme: this.scheme
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
          var err;

          try {
            data = JSON.parse(data);
          } catch (_error) {
            err = _error;
          }
          if (res.statusCode !== expects) {
            err = {
              code: res.statusCode,
              options: opts,
              query: query,
              response: data
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
            var callback, source, _ref1;

            if (err != null) {
              return fn(err);
            }
            if (params.name != null) {
              name = params.name;
            } else {
              params.name = name;
            }
            if (((_ref1 = params.source) != null ? _ref1.name : void 0) != null) {
              source = res[params.source.name];
            } else {
              source = res[name];
            }
            source = source || _this;
            callback = function(err, source) {
              if (err != null) {
                return fn(err);
              }
              res[name] = source;
              return fn(null, name);
            };
            return params.type.create(source, params, callback);
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

    Client.prototype.sources = function(fn) {
      var options;

      options = {
        method: "GET",
        path: "/sources"
      };
      return this.http_request(options, fn);
    };

    return Client;

  })();

}).call(this);
