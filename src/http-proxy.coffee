# https://www.npmjs.com/package/http-proxy
nodeHttpProxy = require 'http-proxy'


class HttpProxy


  constructor: (@server, @ip, @port) ->
    @logger.info 'HttpProxy.constructor'
    @nodeProxy = nodeHttpProxy.createProxyServer({})
    @nodeProxyOptions =
      target:
        host: @ip
        port: @port
    @server.on 'request', @_onRequest
    @server.on 'upgrade', @_onUpgrade


  _onRequest: (request, response) =>
    @logger.debug 'httpProxy._onRequest'
    @nodeProxy.web(request, response, @nodeProxyOptions)


  _onUpgrade: (request, socket, head) =>
    @logger.debug 'httpProxy._onUpgrade'
    @nodeProxy.ws(request, socket, head)


module.exports = HttpProxy
