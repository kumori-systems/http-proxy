(function() {
  var BASE, debug;

  debug = require('debug');

  BASE = 'http-proxy';

  exports.getLogger = function() {
    return {
      error: debug(BASE + ":error"),
      warn: debug(BASE + ":warn"),
      info: debug(BASE + ":info"),
      debug: debug(BASE + ":debug"),
      silly: debug(BASE + ":silly")
    };
  };

}).call(this);
//# sourceMappingURL=util.js.map