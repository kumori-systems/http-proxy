slaputils = require 'slaputils'
HttpProxy = require('./http-proxy')

slaputils.setLogger [HttpProxy]
slaputils.setParser [HttpProxy]

module.exports = (server, ip, port) ->
  return new HttpProxy(server, ip, port)