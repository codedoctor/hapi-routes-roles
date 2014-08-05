_ = require 'underscore'

module.exports =

  role: (role,baseUrl) ->
    return null unless role

    res = 
      _url : "#{baseUrl}/#{role._id}"
      id : role._id
      name: role.name
      description: role.description
    #accountId
    #isInternal
    res


