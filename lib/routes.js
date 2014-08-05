(function() {
  var Boom, Hoek, helperObjToRest, i18n, validationSchemas, _;

  _ = require('underscore');

  Boom = require('boom');

  Hoek = require("hoek");

  helperObjToRest = require('./helper-obj-to-rest');

  i18n = require('./i18n');

  validationSchemas = require('./validation-schemas');

  module.exports = function(plugin, options) {
    var fnAccountId, fnIsInAdminScope, fnRaise404, fnRolesBaseUrl, hapiIdentityStore, methodsRoles;
    if (options == null) {
      options = {};
    }
    Hoek.assert(options.accountId, i18n.optionsAccountIdRequired);
    Hoek.assert(options.baseUrl, i18n.optionsBaseUrlRequired);
    Hoek.assert(options.routesBaseName, i18n.optionsRoutesBaseNameRequired);
    Hoek.assert(options.serverAdminScopeName, i18n.optionsServerAdminScopeNameRequired);
    hapiIdentityStore = function() {
      return plugin.plugins['hapi-identity-store'];
    };
    Hoek.assert(hapiIdentityStore(), i18n.couldNotFindPlugin);
    methodsRoles = function() {
      return hapiIdentityStore().methods.roles;
    };
    Hoek.assert(methodsRoles(), i18n.couldNotFindMethodsRoles);
    fnRaise404 = function(request, reply) {
      return reply(Boom.notFound("" + i18n.notFoundPrefix + " " + options.baseUrl + request.path));
    };

    /*
    Returns the accountId to use.
     */
    fnAccountId = function(request, cb) {
      return cb(null, options.accountId);
    };
    if (options.accountId && _.isFunction(options.accountId)) {
      fnAccountId = options.fnAccountId;
    }

    /*
    Determines if the current request is in serverAdmin scope
     */
    fnIsInAdminScope = function(request) {
      var scopes, _ref, _ref1;
      scopes = ((_ref = request.auth) != null ? (_ref1 = _ref.credentials) != null ? _ref1.scopes : void 0 : void 0) || [];
      return _.contains(scopes, options.serverAdminScopeName);
    };

    /*
    Builds the base url for roles, defaults to ../roles
     */
    fnRolesBaseUrl = function() {
      return "" + options.baseUrl + "/" + options.routesBaseName;
    };
    plugin.route({
      path: "/" + options.routesBaseName,
      method: "GET",
      config: {
        validate: {
          params: validationSchemas.paramsRolesGet
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, accountId) {
          var isInAdminScope, queryOptions;
          if (err) {
            return reply(err);
          }
          isInAdminScope = fnIsInAdminScope(request);
          queryOptions = {};
          if (!isInAdminScope) {
            queryOptions.where = {
              isInternal: false
            };
          }

          /*
          @TODO Options from query, sort, pagination
          file isInternal based on scope
           */
          return methodsRoles().all(accountId, queryOptions, function(err, rolesResult) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            baseUrl = fnRolesBaseUrl();
            rolesResult.items = _.map(rolesResult.items, function(x) {
              return helperObjToRest.role(x, baseUrl, isInAdminScope);
            });

            /*
            @TODO Paginate result and stuff, and transform
             */
            return reply(rolesResult);
          });
        });
      }
    });
    plugin.route({
      path: "/" + options.routesBaseName,
      method: "POST",
      config: {
        validate: {
          params: validationSchemas.paramsRolesPost,
          payload: validationSchemas.payloadRolesPost
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, accountId) {
          if (err) {
            return reply(err);
          }
          return methodsRoles().getByNameOrId(options.accountId, rolenameOrIdOrMe, null, function(err, role) {
            var profile, provider, v1, v2;
            if (err) {
              return reply(err);
            }
            if (!role) {
              return fnRaise404(request, reply);
            }
            provider = request.payload.provider;
            v1 = request.payload.v1;
            v2 = request.payload.v2;
            profile = request.payload.profile || {};

            /*
            @TODO This does not work as expected.
             */
            return methodsRoles().addIdentityToUser(role._id, provider, v1, v2, profile, null, (function(_this) {
              return function(err, role, identity) {
                var baseUrl;
                if (err) {
                  return reply(err);
                }
                baseUrl = fnRolesBaseUrl();
                return reply(helperObjToRest.toles(role, baseUrl)).code(201);
              };
            })(this));
          });
        });
      }
    });
    return plugin.route({
      path: "/" + options.routesBaseName + "/{roleId}",
      method: "DELETE",
      config: {
        validate: {
          params: validationSchemas.paramsRolesDelete
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, accountId) {
          if (err) {
            return reply(err);
          }
          return methodsRoles().getByNameOrId(options.accountId, rolenameOrIdOrMe, null, function(err, role) {
            if (err) {
              return reply(err);
            }
            if (!role) {
              return reply().code(204);
            }
            return methodsRoles().removeIdentityFromUser(role._id, request.params.authorizationId, function(err) {
              if (err) {
                return reply(err);
              }
              return reply().code(204);
            });
          });
        });
      }
    });
  };

}).call(this);

//# sourceMappingURL=routes.js.map
