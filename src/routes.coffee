_ = require 'underscore'
Boom = require 'boom'
Hoek = require "hoek"

helperObjToRest = require './helper-obj-to-rest'
i18n = require './i18n'
validationSchemas = require './validation-schemas'

module.exports = (plugin,options = {}) ->
  Hoek.assert options.accountId, i18n.optionsAccountIdRequired
  Hoek.assert options.baseUrl,i18n.optionsBaseUrlRequired
  Hoek.assert options.routesBaseName,i18n.optionsRoutesBaseNameRequired
  Hoek.assert options.adminScopeName,i18n.optionsAdminScopeNameRequired

  hapiIdentityStore = -> plugin.plugins['hapi-identity-store']
  Hoek.assert hapiIdentityStore(),i18n.couldNotFindPlugin

  methodsRoles = -> hapiIdentityStore().methods.roles

  Hoek.assert methodsRoles(),i18n.couldNotFindMethodsRoles

  fnRaise404 = (request,reply) ->
    reply Boom.notFound("#{i18n.notFoundPrefix} #{options.baseUrl}#{request.path}")

  ###
  Returns the accountId to use. In the basic implementation this is taken from the options, but it can be overriden in the options.
  ###
  fnAccountId = (request,cb) ->
    cb null, options.accountId

  fnAccountId = options.fnAccountId if options.accountId and _.isFunction(options.accountId)

  fnIsInAdminScope = (request) ->
    #return false unless options.adminScopeName
    scopes = (request.auth?.credentials?.scopes) || []
    return _.contains scopes,options.adminScopeName

  ###
  @TODO PATCH, GET ONE
  ###

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

        queryOptions = {}

        isInAdminScope = fnIsInAdminScope(request)

        unless isInAdminScope
          queryOptions.where =
            isInternal : false

        ###
        @TODO Options from query, sort, pagination
        file isInternal based on scope
        ###
        methodsRoles().all accountId, queryOptions,  (err,rolesResult) ->
          return reply err if err

          baseUrl = fnRolesBaseUrl()

          rolesResult.items = _.map(rolesResult.items, (x) -> helperObjToRest.role(x,baseUrl,isInAdminScope) )   

          ###
          @TODO Paginate result and stuff, and transform
          ###

          reply rolesResult

  
  plugin.route
    path: "/#{options.routesBaseName}"
    method: "POST"
    config:
      validate:
        params: validationSchemas.paramsRolesPost
        payload:validationSchemas.payloadRolesPost
    handler: (request, reply) ->
      fnAccountId request, (err,accountId) ->
        return reply err if err

        methodsRoles().getByNameOrId options.accountId, rolenameOrIdOrMe,null,  (err,role) ->
          return reply err if err
          return fnRaise404(request,reply) unless role

          provider = request.payload.provider
          v1 = request.payload.v1
          v2 = request.payload.v2
          profile = request.payload.profile || {}

          ###
          @TODO This does not work as expected.
          ###
          methodsRoles().addIdentityToUser role._id, provider,v1, v2, profile,null,  (err,role,identity) =>
            return reply err if err

            baseUrl = fnRolesBaseUrl()

            reply(helperObjToRest.toles(role,baseUrl)).code(201)

  plugin.route
    path: "/#{options.routesBaseName}/{roleId}"
    method: "DELETE"
    config:
      validate:
        params: validationSchemas.paramsRolesDelete
    handler: (request, reply) ->
      fnAccountId request, (err,accountId) ->
        return reply err if err

        methodsRoles().getByNameOrId options.accountId, rolenameOrIdOrMe,null,  (err,role) ->
          return reply err if err
          return reply().code(204) unless role # no role -> deleted

          methodsRoles().removeIdentityFromUser role._id, request.params.authorizationId, (err) ->
            return reply err if err
            reply().code(204)

