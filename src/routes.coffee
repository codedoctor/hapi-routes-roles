_ = require 'underscore'
Boom = require 'boom'
Hoek = require "hoek"

helperObjToRest = require './helper-obj-to-rest'
i18n = require './i18n'
validationSchemas = require './validation-schemas'
PagingUrlHelper = require './paging-url-helper'
parseMyInt = require './parse-my-int'

module.exports = (plugin,options = {}) ->
  Hoek.assert options.accountId, i18n.optionsAccountIdRequired
  Hoek.assert options.baseUrl,i18n.optionsBaseUrlRequired
  Hoek.assert options.routesBaseName,i18n.optionsRoutesBaseNameRequired
  Hoek.assert options.serverAdminScopeName,i18n.optionsServerAdminScopeNameRequired

  hapiIdentityStore = -> plugin.plugins['hapi-identity-store']
  Hoek.assert hapiIdentityStore(),i18n.couldNotFindPlugin

  methodsRoles = -> hapiIdentityStore().methods.roles
  Hoek.assert methodsRoles(),i18n.couldNotFindMethodsRoles

  fnRaise404 = (request,reply) ->
    reply Boom.notFound("#{i18n.notFoundPrefix} #{options.baseUrl}#{request.path}")

  ###
  Returns the accountId to use.
  ###
  fnAccountId = (request,cb) ->
    cb null, options.accountId

  fnAccountId = options.fnAccountId if options.accountId and _.isFunction(options.accountId)

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
      validate:
        params: validationSchemas.paramsRolesGet
    handler: (request, reply) ->
      fnAccountId request, (err,accountId) ->
        return reply err if err

        isInServerAdmin = fnIsInServerAdmin(request)

        queryOptions = {}
        queryOptions.offset = parseMyInt(request.query.offset,0)
        queryOptions.count = parseMyInt(request.query.count,20)
        queryOptions.where = isInternal : false unless isInServerAdmin

        methodsRoles().all accountId, queryOptions,  (err,rolesResult) ->
          return reply err if err

          baseUrl = fnRolesBaseUrl()

          rolesResult.items = _.map(rolesResult.items, (x) -> helperObjToRest.role(x,baseUrl,isInServerAdmin) )   

          pp = new PagingUrlHelper queryOptions.offset,queryOptions.count, rolesResult.totalCount,request.url

          reply pp.convertToRest( rolesResult)

  
  plugin.route
    path: "/#{options.routesBaseName}"
    method: "POST"
    config:
      validate:
        payload: validationSchemas.payloadRolesPost
    handler: (request, reply) ->
      fnAccountId request, (err,accountId) ->
        return reply err if err
        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        isInServerAdmin = fnIsInServerAdmin(request)
        return reply Boom.forbidden("'#{options.serverAdminScopeName}' #{i18n.serverAdminScopeRequired}") unless isInServerAdmin

        methodsRoles().create accountId, request.payload, null,  (err,role) ->
          return reply err if err

          baseUrl = fnRolesBaseUrl()
          reply(helperObjToRest.role(role,baseUrl,isInServerAdmin)).code(201)


  plugin.route
    path: "/#{options.routesBaseName}/{roleId}"
    method: "DELETE"
    config:
      validate:
        params: validationSchemas.paramsRolesDelete
    handler: (request, reply) ->
      fnAccountId request, (err,accountId) ->
        return reply err if err

        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        isInServerAdmin = fnIsInServerAdmin(request)
        return reply Boom.forbidden("'#{options.serverAdminScopeName}' #{i18n.serverAdminScopeRequired}") unless isInServerAdmin

        methodsRoles().destroy request.params.roleId, null,  (err,role) ->
          return reply err if err
          
          reply().code(204)

