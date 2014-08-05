Hoek = require 'hoek'

i18n = require './i18n'
routes = require './routes'

###
options:
  accountId: 'some mongodb guid' or a function fn(request,cb) -> cb null,accountId
  baseUrl: This is the url to your api. For example https://api.mystuff.com
  routesBaseName: defaults to 'roles'
###
module.exports.register = (plugin, options = {}, cb) ->

  defaults =
    routesBaseName: "roles"
  options = Hoek.applyToDefaults defaults, options

  routes plugin,options

  plugin.expose 'i18n',i18n

  cb()

module.exports.register.attributes =
  pkg: require '../package.json'

