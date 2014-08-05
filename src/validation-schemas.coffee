Joi = require "joi"

validateId = Joi.string().length(24)

module.exports =
  validateId: validateId

  paramsRolesDelete: Joi.object().keys(
      roleId: validateId.required() 
    )

  paramsRolesPatch: Joi.object().keys(
      roleId: validateId.required() 
    )


  paramsRolesGet: Joi.object().keys()

  payloadRolesPatch: Joi.object().keys().options({ allowUnkown: true, stripUnknown: false }) 
  payloadRolesPost: Joi.object().keys().options({ allowUnkown: true, stripUnknown: false })

###
.keys(
    name: Joi.string().min(1).max(100).required().example('role1').description('The name of this role')
    description: Joi.string().length(100).description('The end user description for this role')
    isInternal: Joi.boolean().default(false).description('True when used internally, otherwise visible to end users.')

  )
###
