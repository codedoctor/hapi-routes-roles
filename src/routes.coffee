_ = require 'underscore'
apiPagination = require 'api-pagination'
Boom = require 'boom'
Hoek = require "hoek"

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
    path: "/#{options.routesBaseName}"
    method: "GET"
    config:
      description: options.descriptionGetAll
      tags: options.routeTagsPublic
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err

        isInServerAdmin = fnIsInScopeOrRole(request)

        queryOptions = {}
        queryOptions.offset = apiPagination.parseInt(request.query.offset,0)
        queryOptions.count = apiPagination.parseInt(request.query.count,20)
        queryOptions.where = isInternal : false unless isInServerAdmin

        methodsRoles().all _tenantId, queryOptions,  (err,rolesResult) ->
          return reply err if err

          baseUrl = fnRolesBaseUrl()

          rolesResult.items = _.map(rolesResult.items, (x) -> helperObjToRestRole(x,baseUrl,isInServerAdmin) )   

          reply( apiPagination.toRest( rolesResult,baseUrl))

  
  server.route
    path: "/#{options.routesBaseName}"
    method: "POST"
    config:
      description: options.descriptionPost
      tags: options.routeTagsPublic
      validate:
        payload: validationSchemas.payloadRolesPost
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err
        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        isInServerAdmin = fnIsInScopeOrRole(request)
        return reply Boom.forbidden("'#{options.serverAdminScopeName}' #{i18n.serverAdminScopeRequired}") unless isInServerAdmin

        methodsRoles().create _tenantId, request.payload, null,  (err,role) ->
          return reply err if err

          baseUrl = fnRolesBaseUrl()
          reply(helperObjToRestRole(role,baseUrl,isInServerAdmin)).code(201)


  server.route
    path: "/#{options.routesBaseName}/{roleId}"
    method: "DELETE"
    config:
      description: options.descriptionDeleteOne
      tags: options.routeTagsPublic
      validate:
        params: validationSchemas.paramsRolesDelete
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err

        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        isInServerAdmin = fnIsInScopeOrRole(request)
        return reply Boom.forbidden("'#{options.serverAdminScopeName}' #{i18n.serverAdminScopeRequired}") unless isInServerAdmin

        methodsRoles().destroy request.params.roleId, null,  (err,role) ->
          return reply err if err
          
          reply().code(204)

  server.route
    path: "/#{options.routesBaseName}/{roleId}"
    method: "PATCH"
    config:
      description: options.descriptionPatchOne
      tags: options.routeTagsPublic
      validate:
        params: validationSchemas.paramsRolesPatch
        payload: validationSchemas.payloadRolesPatch
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

  server.route
    path: "/#{options.routesBaseName}/{roleId}"
    method: "GET"
    config:
      description: options.descriptionGetOne
      tags: options.routeTagsPublic
      validate:
        params: validationSchemas.paramsRolesGetOne
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err

        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        
        isInServerAdmin = fnIsInScopeOrRole(request)

        methodsRoles().get request.params.roleId,  null,  (err,role) ->
          return reply err if err
          return reply Boom.notFound(request.url) unless role

          baseUrl = fnRolesBaseUrl()
          reply(helperObjToRestRole(role,baseUrl,isInServerAdmin)).code(200)

