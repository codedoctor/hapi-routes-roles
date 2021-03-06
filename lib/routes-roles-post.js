(function() {
  var Boom, Hoek, Joi, _, apiPagination, helperObjToRestRole, i18n, validationSchemas;

  _ = require('underscore');

  apiPagination = require('api-pagination');

  Boom = require('boom');

  Hoek = require("hoek");

  Joi = require('joi');

  helperObjToRestRole = require('./helper-obj-to-rest-role');

  i18n = require('./i18n');

  validationSchemas = require('./validation-schemas');

  module.exports = function(server, options) {
    var fnAccountId, fnIsInScopeOrRole, fnRolesBaseUrl, hapiUserStoreMultiTenant, methodsRoles;
    if (options == null) {
      options = {};
    }
    Hoek.assert(options._tenantId, i18n.optionsAccountIdRequired);
    Hoek.assert(options.baseUrl, i18n.optionsBaseUrlRequired);
    Hoek.assert(options.routesBaseName, i18n.optionsRoutesBaseNameRequired);
    Hoek.assert(options.serverAdminScopeName, i18n.optionsServerAdminScopeNameRequired);
    Hoek.assert(options.routeTagsPublic && _.isArray(options.routeTagsPublic), i18n.optionsRouteTagsPublicRequiredAndArray);
    Hoek.assert(options.descriptionGetAll, i18n.optionsDescriptionGetAllRequired);
    Hoek.assert(options.descriptionPost, i18n.optionsDescriptionPostRequired);
    Hoek.assert(options.descriptionGetOne, i18n.optionsDescriptionGetOneRequired);
    Hoek.assert(options.descriptionDeleteOne, i18n.optionsDescriptionDeleteOneRequired);
    Hoek.assert(options.descriptionPatchOne, i18n.optionsDescriptionPatchOneRequired);
    hapiUserStoreMultiTenant = function() {
      return server.plugins['hapi-user-store-multi-tenant'];
    };
    Hoek.assert(hapiUserStoreMultiTenant(), i18n.couldNotFindPlugin);
    methodsRoles = function() {
      return hapiUserStoreMultiTenant().methods.roles;
    };
    Hoek.assert(methodsRoles(), i18n.couldNotFindMethodsRoles);

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
    fnIsInScopeOrRole = function(request) {
      var isInRole, isInScope, ref, ref1, ref2, ref3, roles, scopes;
      scopes = ((ref = request.auth) != null ? (ref1 = ref.credentials) != null ? ref1.scopes : void 0 : void 0) || [];
      roles = ((ref2 = request.auth) != null ? (ref3 = ref2.credentials) != null ? ref3.roles : void 0 : void 0) || [];
      isInScope = _.contains(scopes, options.serverAdminScopeName);
      isInRole = _.contains(roles, options.adminRolesName);
      return isInScope || isInRole;
    };

    /*
    Builds the base url for roles, defaults to ../roles
     */
    fnRolesBaseUrl = function() {
      return options.baseUrl + "/" + options.routesBaseName;
    };
    return server.route({
      path: "/" + options.routesBaseName,
      method: "POST",
      config: {
        description: options.descriptionPost,
        tags: options.routeTagsPublic,
        validate: {
          payload: Joi.object().keys().options({
            allowUnknown: true,
            stripUnknown: false
          })
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, _tenantId) {
          var isInServerAdmin, ref;
          if (err) {
            return reply(err);
          }
          if (!((ref = request.auth) != null ? ref.credentials : void 0)) {
            return reply(Boom.unauthorized(i18n.authorizationRequired));
          }
          isInServerAdmin = fnIsInScopeOrRole(request);
          if (!isInServerAdmin) {
            return reply(Boom.forbidden("'" + options.serverAdminScopeName + "' " + i18n.serverAdminScopeRequired));
          }
          return methodsRoles().create(_tenantId, request.payload, null, function(err, role) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            baseUrl = fnRolesBaseUrl();
            return reply(helperObjToRestRole(role, baseUrl, isInServerAdmin)).code(201);
          });
        });
      }
    });
  };

}).call(this);

//# sourceMappingURL=routes-roles-post.js.map
