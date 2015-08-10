Joi = require "joi"
i18n = require "./i18n"

validateId = Joi.string().length(24)
roleId = validateId.description(i18n.descriptionRoleId).example(i18n.exampleObjectId) 

module.exports =
  roleId: roleId

  paramsRolesDelete: Joi.object().keys(
      roleId: roleId.required()
    )

  paramsRolesPatch: Joi.object().keys(
      roleId: roleId.required() 
    )

  paramsRolesGetOne: Joi.object().keys(
      roleId: roleId.required() 
    )

  payloadRolesPatch: Joi.object().keys().options({ allowUnknown: true, stripUnknown: false }) 
  payloadRolesPost: Joi.object().keys().options({ allowUnknown: true, stripUnknown: false })

###
.keys(
    name: Joi.string().min(1).max(100).required().example('role1').description('The name of this role')
    description: Joi.string().length(100).description('The end user description for this role')
    isInternal: Joi.boolean().default(false).description('True when used internally, otherwise visible to end users.')

  )
###
