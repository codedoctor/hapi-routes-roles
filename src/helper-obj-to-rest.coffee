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
      res.accountId = role.accountId
      res.isInternal = role.isInternal

    res


