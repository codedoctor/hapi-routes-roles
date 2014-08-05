(function() {
  var Hoek, i18n, routes;

  Hoek = require('hoek');

  i18n = require('./i18n');

  routes = require('./routes');


  /*
  options:
    accountId: 'some mongodb guid' or a function fn(request,cb) -> cb null,accountId
    baseUrl: This is the url to your api. For example https://api.mystuff.com
    routesBasePath: defaults to '/roles'
   */

  module.exports.register = function(plugin, options, cb) {
    var defaults;
    if (options == null) {
      options = {};
    }
    defaults = {
      routesBasePath: "/roles"
    };
    options = Hoek.applyToDefaults(defaults, options);
    routes(plugin, options);
    plugin.expose('i18n', i18n);
    return cb();
  };

  module.exports.register.attributes = {
    pkg: require('../package.json')
  };

}).call(this);

//# sourceMappingURL=index.js.map
