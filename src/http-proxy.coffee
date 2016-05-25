# https://www.npmjs.com/package/http-proxy
nodeHttpProxy = require 'http-proxy'


class HttpProxy


  constructor: (@server, @ip, @port) ->
    method = 'HttpProxy.constructor'
    @logger.info "#{method}"
    @nodeProxy = nodeHttpProxy.createProxyServer({})
    @nodeProxyOptions =
      target:
        host: @ip
        port: @port
    @server.on 'request', @_onRequest


  _onRequest: (request, response) =>
    method = 'httpProxy._onRequest'
    @logger.debug "#{method}"
    @nodeProxy.web(request, response, @nodeProxyOptions)


module.exports = HttpProxy
