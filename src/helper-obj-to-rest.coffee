_ = require 'underscore'

module.exports =

  role: (role,baseUrl,isInAdminScope) ->
    return null unless role

    res = 
      _url : "#{baseUrl}/#{role._id}"
      id : role._id
      name: role.name
      description: role.description

    if isInAdminScope
      res._tenantId = role._tenantId
      res.isInternal = role.isInternal

    res


