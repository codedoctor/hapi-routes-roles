(function() {
  var Boom, Hoek, apiPagination, helperObjToRest, i18n, validationSchemas, _;

  _ = require('underscore');

  apiPagination = require('api-pagination');

  Boom = require('boom');

  Hoek = require("hoek");

  helperObjToRest = require('./helper-obj-to-rest');

  i18n = require('./i18n');

  validationSchemas = require('./validation-schemas');

  module.exports = function(plugin, options) {
    var fnAccountId, fnIsInServerAdmin, fnRaise404, fnRolesBaseUrl, hapiUserStoreMultiTenant, methodsRoles;
    if (options == null) {
      options = {};
    }
    Hoek.assert(options._tenantId, i18n.optionsAccountIdRequired);
    Hoek.assert(options.baseUrl, i18n.optionsBaseUrlRequired);
    Hoek.assert(options.routesBaseName, i18n.optionsRoutesBaseNameRequired);
    Hoek.assert(options.serverAdminScopeName, i18n.optionsServerAdminScopeNameRequired);
    hapiUserStoreMultiTenant = function() {
      return plugin.plugins['hapi-user-store-multi-tenant'];
    };
    Hoek.assert(hapiUserStoreMultiTenant(), i18n.couldNotFindPlugin);
    methodsRoles = function() {
      return hapiUserStoreMultiTenant().methods.roles;
    };
    Hoek.assert(methodsRoles(), i18n.couldNotFindMethodsRoles);
    fnRaise404 = function(request, reply) {
      return reply(Boom.notFound("" + i18n.notFoundPrefix + " " + options.baseUrl + request.path));
    };

    /*
    Returns the _tenantId to use.
     */
    fnAccountId = function(request, cb) {
      return cb(null, options._tenantId);
    };
    if (options._tenantId && _.isFunction(options._tenantId)) {
      fnAccountId = options.fnAccountId;
    }

    /*
    Determines if the current request is in serverAdmin scope
     */
    fnIsInServerAdmin = function(request) {
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
        return fnAccountId(request, function(err, _tenantId) {
          var isInServerAdmin, queryOptions;
          if (err) {
            return reply(err);
          }
          isInServerAdmin = fnIsInServerAdmin(request);
          queryOptions = {};
          queryOptions.offset = apiPagination.parseInt(request.query.offset, 0);
          queryOptions.count = apiPagination.parseInt(request.query.count, 20);
          if (!isInServerAdmin) {
            queryOptions.where = {
              isInternal: false
            };
          }
          return methodsRoles().all(_tenantId, queryOptions, function(err, rolesResult) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            baseUrl = fnRolesBaseUrl();
            rolesResult.items = _.map(rolesResult.items, function(x) {
              return helperObjToRest.role(x, baseUrl, isInServerAdmin);
            });
            return reply(apiPagination.toRest(rolesResult, baseUrl));
          });
        });
      }
    });
    plugin.route({
      path: "/" + options.routesBaseName,
      method: "POST",
      config: {
        validate: {
          payload: validationSchemas.payloadRolesPost
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, _tenantId) {
          var isInServerAdmin, _ref;
          if (err) {
            return reply(err);
          }
          if (!((_ref = request.auth) != null ? _ref.credentials : void 0)) {
            return reply(Boom.unauthorized(i18n.authorizationRequired));
          }
          isInServerAdmin = fnIsInServerAdmin(request);
          if (!isInServerAdmin) {
            return reply(Boom.forbidden("'" + options.serverAdminScopeName + "' " + i18n.serverAdminScopeRequired));
          }
          return methodsRoles().create(_tenantId, request.payload, null, function(err, role) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            baseUrl = fnRolesBaseUrl();
            return reply(helperObjToRest.role(role, baseUrl, isInServerAdmin)).code(201);
          });
        });
      }
    });
    plugin.route({
      path: "/" + options.routesBaseName + "/{roleId}",
      method: "DELETE",
      config: {
        validate: {
          params: validationSchemas.paramsRolesDelete
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, _tenantId) {
          var isInServerAdmin, _ref;
          if (err) {
            return reply(err);
          }
          if (!((_ref = request.auth) != null ? _ref.credentials : void 0)) {
            return reply(Boom.unauthorized(i18n.authorizationRequired));
          }
          isInServerAdmin = fnIsInServerAdmin(request);
          if (!isInServerAdmin) {
            return reply(Boom.forbidden("'" + options.serverAdminScopeName + "' " + i18n.serverAdminScopeRequired));
          }
          return methodsRoles().destroy(request.params.roleId, null, function(err, role) {
            if (err) {
              return reply(err);
            }
            return reply().code(204);
          });
        });
      }
    });
    plugin.route({
      path: "/" + options.routesBaseName + "/{roleId}",
      method: "PATCH",
      config: {
        validate: {
          params: validationSchemas.paramsRolesPatch,
          payload: validationSchemas.payloadRolesPatch
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, _tenantId) {
          var isInServerAdmin, _ref;
          if (err) {
            return reply(err);
          }
          if (!((_ref = request.auth) != null ? _ref.credentials : void 0)) {
            return reply(Boom.unauthorized(i18n.authorizationRequired));
          }
          isInServerAdmin = fnIsInServerAdmin(request);
          if (!isInServerAdmin) {
            return reply(Boom.forbidden("'" + options.serverAdminScopeName + "' " + i18n.serverAdminScopeRequired));
          }
          return methodsRoles().get(request.params.roleId, null, function(err, role) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            if (!role) {
              return reply(Boom.notFound(request.url));
            }
            baseUrl = fnRolesBaseUrl();
            return methodsRoles().patch(request.params.roleId, request.payload, null, function(err, role) {
              if (err) {
                return reply(err);
              }
              return reply(helperObjToRest.role(role, baseUrl, isInServerAdmin)).code(200);
            });
          });
        });
      }
    });
    return plugin.route({
      path: "/" + options.routesBaseName + "/{roleId}",
      method: "GET",
      config: {
        validate: {
          params: validationSchemas.paramsRolesGetOne
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, _tenantId) {
          var isInServerAdmin, _ref;
          if (err) {
            return reply(err);
          }
          if (!((_ref = request.auth) != null ? _ref.credentials : void 0)) {
            return reply(Boom.unauthorized(i18n.authorizationRequired));
          }
          isInServerAdmin = fnIsInServerAdmin(request);
          return methodsRoles().get(request.params.roleId, null, function(err, role) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            if (!role) {
              return reply(Boom.notFound(request.url));
            }
            baseUrl = fnRolesBaseUrl();
            return reply(helperObjToRest.role(role, baseUrl, isInServerAdmin)).code(200);
          });
        });
      }
    });
  };

}).call(this);

//# sourceMappingURL=routes.js.map
