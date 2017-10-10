slaputils = require 'slaputils'
HttpProxy = require('./http-proxy')

slaputils.setParser [HttpProxy]

module.exports = (server, ip, port) ->
  return new HttpProxy(server, ip, port)

module.exports._loggerDependencies = () -> return [HttpProxy]

