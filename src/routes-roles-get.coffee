_ = require 'underscore'
apiPagination = require 'api-pagination'
Boom = require 'boom'
Hoek = require "hoek"
Joi = require 'Joi'

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

  