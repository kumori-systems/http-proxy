(function() {
  var EventEmitter, HttpProxy, debug, kutil, nodeHttpProxy,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  nodeHttpProxy = require('http-proxy');

  EventEmitter = require('events');

  debug = require('debug');

  kutil = require('./util');

  HttpProxy = (function(superClass) {
    extend(HttpProxy, superClass);

    function HttpProxy(server, ip, port) {
      this.server = server;
      this.ip = ip;
      this.port = port;
      this._onError = bind(this._onError, this);
      this._onUpgrade = bind(this._onUpgrade, this);
      this._onRequest = bind(this._onRequest, this);
      if (this.logger == null) {
        this.logger = kutil.getLogger();
      }
      this.logger.info('HttpProxy.constructor');
      this.nodeProxy = nodeHttpProxy.createProxyServer({
        target: {
          host: this.ip,
          port: this.port
        }
      });
      this.server.on('request', this._onRequest);
      this.server.on('upgrade', this._onUpgrade);
      this.nodeProxy.on('error', this._onError);
    }

    HttpProxy.prototype._onRequest = function(request, response) {
      this.logger.debug('httpProxy._onRequest');
      return this.nodeProxy.web(request, response);
    };

    HttpProxy.prototype._onUpgrade = function(request, socket, head) {
      this.logger.debug('httpProxy._onUpgrade');
      return this.nodeProxy.ws(request, socket, head);
    };

    HttpProxy.prototype._onError = function(error) {
      this.logger.warn("HttpProxy._onError. Error received: " + error);
      return this.emit('error', error);
    };

    return HttpProxy;

  })(EventEmitter);

  module.exports.HttpProxy = HttpProxy;

}).call(this);
//# sourceMappingURL=http-proxy.js.map