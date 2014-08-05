###
@author Martin Wawrusch (martin@wawrusch.com)
###

Hoek = require 'hoek'
i18n = require './i18n'
routes = require './routes'

###
Main entry point for the plugin

@param [Plugin] plugin the HAPI plugin
@param [Object] options the plugin options
@option options [String|Function] accountId the account id to use, or an async function.
@option options [String] baseUrl the url to your API. For example https://api.mystuff.com
@option options [String] routesBaseName the name of the endpoints, defaults to role.
@option options [String] serverAdminScopeName the name of the serverAdmin scope, defaults to serverAdmin.
@param [Function] cb the callback invoked after completion

When passing a function to the accountId the signature needs to be as follows:

```coffeescript
  fnAccountId = (request,cb) ->
    accountId = null
    # lookup accountId here ...
    cb null, accountId

```
###
module.exports.register = (plugin, options = {}, cb) ->

  defaults =
    routesBaseName: 'roles'
    serverAdminScopeName: 'server-admin'
  options = Hoek.applyToDefaults defaults, options

  routes plugin,options

  plugin.expose 'i18n',i18n

  cb()

###
@nodoc
###
module.exports.register.attributes =
  pkg: require '../package.json'

