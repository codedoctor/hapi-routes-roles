
/*
@author Martin Wawrusch (martin@wawrusch.com)
 */

(function() {
  var Hoek, i18n, routes;

  Hoek = require('hoek');

  i18n = require('./i18n');

  routes = require('./routes');


  /*
  Main entry point for the plugin
  
  @param [Plugin] plugin the HAPI plugin
  @param [Object] options the plugin options
  @option options [String|Function] _tenantId the account id to use, or an async function.
  @option options [String] baseUrl the url to your API. For example https://api.mystuff.com
  @option options [String] routesBaseName the name of the endpoints, defaults to role.
  @option options [String] serverAdminScopeName the name of the serverAdmin scope, defaults to serverAdmin.
  @option options [Array] tags the tags applied to the route, defaults to 'identity' and 'role'. Can be an empty array.
  @option options [String] descriptionGetAll the description for the GET /roles endpoint.
  @option options [String] descriptionPost the description for the POST /roles endpoint.
  @option options [String] descriptionPatchOne the description for the PATCH /roles/{roleId} endpoint.
  @option options [String] descriptionDeleteOne the description for the DELETE /roles/{roleId} endpoint.
  @option options [String] descriptionGetOne the description for the GET /roles/{roleId} endpoint.
  
  @param [Function] cb the callback invoked after completion
  
  When passing a function to the _tenantId the signature needs to be as follows:
  
  ```coffeescript
    fnAccountId = (request,cb) ->
      _tenantId = null
       * lookup _tenantId here ...
      cb null, _tenantId
  
  ```
   */

  module.exports.register = function(plugin, options, cb) {
    var defaults;
    if (options == null) {
      options = {};
    }
    defaults = {
      routesBaseName: 'roles',
      serverAdminScopeName: 'server-admin',
      tags: ['identity', 'roles'],
      descriptionGetAll: i18n.descriptionGetAll,
      descriptionPost: i18n.descriptionPost,
      descriptionGetOne: i18n.descriptionGetOne,
      descriptionDeleteOne: i18n.descriptionDeleteOne,
      descriptionPatchOne: i18n.descriptionPatchOne
    };
    options = Hoek.applyToDefaults(defaults, options);
    routes(plugin, options);
    plugin.expose('i18n', i18n);
    return cb();
  };


  /*
  @nodoc
   */

  module.exports.register.attributes = {
    pkg: require('../package.json')
  };

}).call(this);

//# sourceMappingURL=index.js.map
