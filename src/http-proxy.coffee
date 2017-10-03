nodeHttpProxy = require 'http-proxy'
EventEmitter = require 'events'
slaputils = require 'slaputils'


class HttpProxy extends EventEmitter

  constructor: (@server, @ip, @port) ->
    if not @logger? # If logger hasn't been injected from outside
      slaputils.setLogger [HttpProxy]
    @logger.info 'HttpProxy.constructor'
    @nodeProxy = nodeHttpProxy.createProxyServer
      target:
        host: @ip
        port: @port
    @server.on 'request', @_onRequest
    @server.on 'upgrade', @_onUpgrade
    @nodeProxy.on 'error', @_onError


  _onRequest: (request, response) =>
    @logger.debug 'httpProxy._onRequest'
    @nodeProxy.web request, response


  _onUpgrade: (request, socket, head) =>
    @logger.debug 'httpProxy._onUpgrade'
    @nodeProxy.ws request, socket, head


  _onError: (error) =>
    # Nodejitsu http-proxy documentation:
    # Listening for proxy events
    #   error: The error event is emitted if the request to the target fail.
    #   We do not do any error handling of messages passed between client and
    #   proxy, and messages passed between proxy and target, so it is
    #   recommended that you listen on errors and handle them.
    @logger.warn "HttpProxy._onError. Error received: #{error}"
    @emit 'error', error


module.exports = HttpProxy
