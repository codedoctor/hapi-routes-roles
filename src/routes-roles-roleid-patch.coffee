_ = require 'underscore'
apiPagination = require 'api-pagination'
Boom = require 'boom'
Hoek = require "hoek"
Joi = require 'joi'

helperObjToRestRole = require './helper-obj-to-rest-role'
i18n = require './i18n'
validationSchemas = require './validation-schemas'

module.exports = (server,options = {}) ->
  Hoek.assert options._tenantId, i18n.optionsAccountIdRequired
  Hoek.assert options.baseUrl,i18n.optionsBaseUrlRequired
  Hoek.assert options.routesBaseName,i18n.optionsRoutesBaseNameRequired
  Hoek.assert options.serverAdminScopeName,i18n.optionsServerAdminScopeNameRequired
  Hoek.assert options.routeTagsPublic && _.isArray(options.routeTagsPublic),i18n.optionsRouteTagsPublicRequiredAndArray

  Hoek.assert options.descriptionGetAll, i18n.optionsDescriptionGetAllRequired
  Hoek.assert options.descriptionPost, i18n.optionsDescriptionPostRequired
  Hoek.assert options.descriptionGetOne, i18n.optionsDescriptionGetOneRequired
  Hoek.assert options.descriptionDeleteOne, i18n.optionsDescriptionDeleteOneRequired
  Hoek.assert options.descriptionPatchOne, i18n.optionsDescriptionPatchOneRequired

  hapiUserStoreMultiTenant = -> server.plugins['hapi-user-store-multi-tenant']
  Hoek.assert hapiUserStoreMultiTenant(),i18n.couldNotFindPlugin

  methodsRoles = -> hapiUserStoreMultiTenant().methods.roles
  Hoek.assert methodsRoles(),i18n.couldNotFindMethodsRoles

  ###
  Returns the _tenantId to use.
  ###
  fnAccountId = (request,cb) ->
    cb null, options._tenantId

  fnAccountId = options.fnAccountId if options._tenantId and _.isFunction(options._tenantId)

  ###
  Determines if the current request is in serverAdmin scope
  ###
  fnIsInScopeOrRole = (request) ->
    scopes = (request.auth?.credentials?.scopes) || []
    roles = (request.auth?.credentials?.roles) || []
    isInScope = _.contains scopes,options.serverAdminScopeName 
    isInRole = _.contains roles,options.adminRolesName 
    return isInScope or isInRole

  ###
  Builds the base url for roles, defaults to ../roles
  ###
  fnRolesBaseUrl = ->
    "#{options.baseUrl}/#{options.routesBaseName}"


  server.route
    path: "/#{options.routesBaseName}/{roleId}"
    method: "PATCH"
    config:
      description: options.descriptionPatchOne
      tags: options.routeTagsPublic
      validate:
        params: Joi.object().keys(
                      roleId: validationSchemas.roleId.required() 
                  )
        payload: Joi.object().keys().options({ allowUnknown: true, stripUnknown: false }) 
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err

        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        isInServerAdmin = fnIsInScopeOrRole(request)
        return reply Boom.forbidden("'#{options.serverAdminScopeName}' #{i18n.serverAdminScopeRequired}") unless isInServerAdmin

        methodsRoles().get request.params.roleId,  null,  (err,role) ->
          return reply err if err
          return reply Boom.notFound(request.url) unless role

          baseUrl = fnRolesBaseUrl()

          methodsRoles().patch request.params.roleId, request.payload, null,  (err,role) ->
            return reply err if err          
            reply(helperObjToRestRole(role,baseUrl,isInServerAdmin)).code(200)
