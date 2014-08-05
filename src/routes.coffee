_ = require 'underscore'
Boom = require 'boom'
Hoek = require "hoek"

helperObjToRest = require './helper-obj-to-rest'
i18n = require './i18n'
validationSchemas = require './validation-schemas'

module.exports = (plugin,options = {}) ->
  Hoek.assert options.accountId, i18n.optionsAccountIdRequired
  Hoek.assert options.baseUrl,i18n.optionsBaseUrlRequired

  hapiIdentityStore = -> plugin.plugins['hapi-identity-store']
  Hoek.assert hapiIdentityStore(),i18n.couldNotFindPlugin

  methodsUsers = -> hapiIdentityStore().methods.users
  methodsOauthAuth = -> hapiIdentityStore().methods.oauthAuth

  Hoek.assert methodsUsers(),i18n.couldNotFindMethodsUsers
  Hoek.assert methodsOauthAuth(), i18n.couldNotFindMethodsOauthAuth 

  fbUsernameFromRequest = (request) ->
    usernameOrIdOrMe = request.params.usernameOrIdOrMe

    if usernameOrIdOrMe.toLowerCase() is 'me'
      return null unless request.auth?.credentials?.id
      usernameOrIdOrMe = request.auth.credentials.id
    return usernameOrIdOrMe

  fnRaise404 = (request,reply) ->
    reply Boom.notFound("#{i18n.notFoundPrefix} #{options.baseUrl}#{request.path}")


  plugin.route
    path: "/users/{usernameOrIdOrMe}/authorizations"
    method: "GET"
    config:
      validate:
        params: validationSchemas.paramsUsersAuthorizationsGet
    handler: (request, reply) ->
      usernameOrIdOrMe = fbUsernameFromRequest request
      return reply Boom.unauthorized(i18n.authorizationRequired) unless usernameOrIdOrMe

      methodsUsers().getByNameOrId options.accountId, usernameOrIdOrMe,null,  (err,user) ->
        return reply err if err
        return fnRaise404(request,reply) unless user

        user.identities ||= []
        baseUrl = "#{options.baseUrl}/users/#{user._id}/authorizations"

        result =
          items: _.map( user.identities, (x) -> helperObjToRest.identity(x,baseUrl)  )
          totalCount: user.identities.length
          requestCount: user.identities.length
          requestOffset: 0 
        reply result

  
  plugin.route
    path: "/users/{usernameOrIdOrMe}/authorizations"
    method: "POST"
    config:
      validate:
        params: validationSchemas.paramsUsersAuthorizationsPost
        payload:validationSchemas.payloadUsersAuthorizationsPost
    handler: (request, reply) ->
      usernameOrIdOrMe = fbUsernameFromRequest request
      return reply Boom.unauthorized(i18n.authorizationRequired) unless usernameOrIdOrMe

      methodsUsers().getByNameOrId options.accountId, usernameOrIdOrMe,null,  (err,user) ->
        return reply err if err
        return fnRaise404(request,reply) unless user

        provider = request.payload.provider
        v1 = request.payload.v1
        v2 = request.payload.v2
        profile = request.payload.profile || {}

        ###
        @TODO This does not work as expected.
        ###
        methodsUsers().addIdentityToUser user._id, provider,v1, v2, profile,null,  (err,user,identity) =>
          return reply err if err

          baseUrl = "#{options.baseUrl}/users/#{user._id}/authorizations"

          reply(helperObjToRest.identity(identity,baseUrl)).code(201)

  plugin.route
    path: "/users/{usernameOrIdOrMe}/authorizations/{authorizationId}"
    method: "DELETE"
    config:
      validate:
        params: validationSchemas.paramsUsersAuthorizationsDelete
    handler: (request, reply) ->
      usernameOrIdOrMe = fbUsernameFromRequest request
      return reply Boom.unauthorized(i18n.authorizationRequired) unless usernameOrIdOrMe

      methodsUsers().getByNameOrId options.accountId, usernameOrIdOrMe,null,  (err,user) ->
        return reply err if err
        return reply().code(204) unless user # no user -> deleted

        methodsUsers().removeIdentityFromUser user._id, request.params.authorizationId, (err) ->
          return reply err if err
          reply().code(204)

