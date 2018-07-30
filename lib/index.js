(function() {
  var HttpProxy;

  HttpProxy = require('./http-proxy').HttpProxy;

  module.exports = function(server, ip, port) {
    return new HttpProxy(server, ip, port);
  };

  module.exports._loggerDependencies = function() {
    return [HttpProxy];
  };

}).call(this);
//# sourceMappingURL=index.js.map