_ = require 'underscore'
apiPagination = require 'api-pagination'
Boom = require 'boom'
Hoek = require "hoek"

helperObjToRest = require './helper-obj-to-rest'
i18n = require './i18n'
validationSchemas = require './validation-schemas'

module.exports = (plugin,options = {}) ->
  Hoek.assert options._tenantId, i18n.optionsAccountIdRequired
  Hoek.assert options.baseUrl,i18n.optionsBaseUrlRequired
  Hoek.assert options.routesBaseName,i18n.optionsRoutesBaseNameRequired
  Hoek.assert options.serverAdminScopeName,i18n.optionsServerAdminScopeNameRequired
  Hoek.assert options.tags && _.isArray(options.tags),i18n.optionsTagsRequiredAndArray
  Hoek.assert options.descriptionGetAll, i18n.optionsDescriptionGetAllRequired

  Hoek.assert options.descriptionGetAll, i18n.optionsDescriptionGetAllRequired
  Hoek.assert options.descriptionPost, i18n.optionsDescriptionPostRequired
  Hoek.assert options.descriptionGetOne, i18n.optionsDescriptionGetOneRequired
  Hoek.assert options.descriptionDeleteOne, i18n.optionsDescriptionDeleteOneRequired
  Hoek.assert options.descriptionPatchOne, i18n.optionsDescriptionPatchOneRequired

  hapiUserStoreMultiTenant = -> plugin.plugins['hapi-user-store-multi-tenant']
  Hoek.assert hapiUserStoreMultiTenant(),i18n.couldNotFindPlugin

  methodsRoles = -> hapiUserStoreMultiTenant().methods.roles
  Hoek.assert methodsRoles(),i18n.couldNotFindMethodsRoles

  fnRaise404 = (request,reply) ->
    reply Boom.notFound("#{i18n.notFoundPrefix} #{options.baseUrl}#{request.path}")

  ###
  Returns the _tenantId to use.
  ###
  fnAccountId = (request,cb) ->
    cb null, options._tenantId

  fnAccountId = options.fnAccountId if options._tenantId and _.isFunction(options._tenantId)

  ###
  Determines if the current request is in serverAdmin scope
  ###
  fnIsInServerAdmin = (request) ->
    scopes = (request.auth?.credentials?.scopes) || []
    return _.contains scopes,options.serverAdminScopeName

  ###
  Builds the base url for roles, defaults to ../roles
  ###
  fnRolesBaseUrl = ->
    "#{options.baseUrl}/#{options.routesBaseName}"

  plugin.route
    path: "/#{options.routesBaseName}"
    method: "GET"
    config:
      description: options.descriptionGetAll
      tags: options.tags
      validate:
        params: validationSchemas.paramsRolesGet
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err

        isInServerAdmin = fnIsInServerAdmin(request)

        queryOptions = {}
        queryOptions.offset = apiPagination.parseInt(request.query.offset,0)
        queryOptions.count = apiPagination.parseInt(request.query.count,20)
        queryOptions.where = isInternal : false unless isInServerAdmin

        methodsRoles().all _tenantId, queryOptions,  (err,rolesResult) ->
          return reply err if err

          baseUrl = fnRolesBaseUrl()

          rolesResult.items = _.map(rolesResult.items, (x) -> helperObjToRest.role(x,baseUrl,isInServerAdmin) )   

          reply( apiPagination.toRest( rolesResult,baseUrl))

  
  plugin.route
    path: "/#{options.routesBaseName}"
    method: "POST"
    config:
      description: options.descriptionPost
      tags: options.tags
      validate:
        payload: validationSchemas.payloadRolesPost
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err
        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        isInServerAdmin = fnIsInServerAdmin(request)
        return reply Boom.forbidden("'#{options.serverAdminScopeName}' #{i18n.serverAdminScopeRequired}") unless isInServerAdmin

        methodsRoles().create _tenantId, request.payload, null,  (err,role) ->
          return reply err if err

          baseUrl = fnRolesBaseUrl()
          reply(helperObjToRest.role(role,baseUrl,isInServerAdmin)).code(201)


  plugin.route
    path: "/#{options.routesBaseName}/{roleId}"
    method: "DELETE"
    config:
      description: options.descriptionDeleteOne
      tags: options.tags
      validate:
        params: validationSchemas.paramsRolesDelete
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err

        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        isInServerAdmin = fnIsInServerAdmin(request)
        return reply Boom.forbidden("'#{options.serverAdminScopeName}' #{i18n.serverAdminScopeRequired}") unless isInServerAdmin

        methodsRoles().destroy request.params.roleId, null,  (err,role) ->
          return reply err if err
          
          reply().code(204)

  plugin.route
    path: "/#{options.routesBaseName}/{roleId}"
    method: "PATCH"
    config:
      description: options.descriptionPatchOne
      tags: options.tags
      validate:
        params: validationSchemas.paramsRolesPatch
        payload: validationSchemas.payloadRolesPatch
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err

        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        isInServerAdmin = fnIsInServerAdmin(request)
        return reply Boom.forbidden("'#{options.serverAdminScopeName}' #{i18n.serverAdminScopeRequired}") unless isInServerAdmin

        methodsRoles().get request.params.roleId,  null,  (err,role) ->
          return reply err if err
          return reply Boom.notFound(request.url) unless role

          baseUrl = fnRolesBaseUrl()

          methodsRoles().patch request.params.roleId, request.payload, null,  (err,role) ->
            return reply err if err          
            reply(helperObjToRest.role(role,baseUrl,isInServerAdmin)).code(200)

  plugin.route
    path: "/#{options.routesBaseName}/{roleId}"
    method: "GET"
    config:
      description: options.descriptionGetOne
      tags: options.tags
      validate:
        params: validationSchemas.paramsRolesGetOne
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err

        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        
        isInServerAdmin = fnIsInServerAdmin(request)

        methodsRoles().get request.params.roleId,  null,  (err,role) ->
          return reply err if err
          return reply Boom.notFound(request.url) unless role

          baseUrl = fnRolesBaseUrl()
          reply(helperObjToRest.role(role,baseUrl,isInServerAdmin)).code(200)

